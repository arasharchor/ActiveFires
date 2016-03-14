import os
import sys
import csv
import json
from ftplib import FTP
from datetime import datetime, timedelta


from geojson import Feature, Point, FeatureCollection


from settings import cfg


def ftp_connection(url, username, password):
    try:
        ftp = FTP(url)
        ftp.login(username, password)
        return ftp
    except:
        print "Failed to connect to ftp site {0}".format(url)
        sys.exit()

def calendar2julian(dt):
    dt = dt.timetuple()
    return int("%d%03d" % (dt.tm_year, dt.tm_yday))

def get_last_n_dates(n=1):
    date_list = list()
    today = datetime.utcnow()
    for i in reversed(range(n)):
        date_list.append(today - timedelta(days=i))
    return date_list

def download_file(ftp_connection, ftp_fname, out_fname):
    outfile = open(out_fname, "wb")
    try:
        ftp_connection.retrbinary("RETR {0}".format(ftp_fname),
                                  outfile.write)
    except:
        print "Failed to download the file {0}".format(ftp_fname)
    outfile.close()

def main():
    connection = ftp_connection(cfg.url, cfg.username, cfg.password)
    connection.cwd("FIRMS/c6/Global")

    root_path = os.path.dirname(os.path.abspath(__file__))
    date_list = get_last_n_dates(n=2)
    satellite_fname = "MODIS_C6_Global_MCD14DL_NRT_{0}.txt"

    outfile = open(cfg.outfile, mode="w")
    feature_collection = list()

    for day in date_list:
        julian_date = calendar2julian(day)
        satellite_file = satellite_fname.format(julian_date)

        if satellite_file not in connection.nlst():
            print "The file {0} does not exist!".format(satellite_file)
            continue

        downloaded_fname = os.path.join(root_path,
                                        "{0}.csv".format(julian_date))
        download_file(connection, satellite_file, downloaded_fname)
        downloaded_file = open(downloaded_fname, "r")

        reader = csv.DictReader(downloaded_file)

        for row in reader:
            # continue if the fire was recorded over 24 hours ago
            acquisition_date = datetime.strptime("{0} {1}".format(row["acq_date"],
                                                                  row["acq_time"]),
                                                 "%Y-%m-%d %H:%M")
            today = datetime.utcnow()
            record_age = (today - acquisition_date).total_seconds()/3600.00

            if record_age > 24.00:
                continue
            else:
                row["record_age"] = int(record_age)
                row["acq_datetime"] = str(acquisition_date)

            point = Point((float(row["longitude"]), float(row["latitude"])))
            feature = Feature(geometry=point)
            for key in row:
                if key not in ["longitude", "latitude", "acq_date", "acq_time"]:
                    feature.properties[key] = row[key]
            feature_collection.append(feature)

        downloaded_file.close()
        os.remove(downloaded_fname)

    geojson_content = FeatureCollection(feature_collection)
    reference_date = datetime(1970, 1, 1, 0, 0)
    geojson_content.features = sorted(geojson_content.features,
                                      key=lambda x: datetime.strptime(x["properties"]["acq_datetime"],
                                                                      "%Y-%m-%d %H:%M:%S"),
                                      reverse=True)

    json.dump(geojson_content, outfile, indent=2,
              separators=(",", ": "))
    outfile.close()
    connection.close()


if __name__ == "__main__":
    main()
