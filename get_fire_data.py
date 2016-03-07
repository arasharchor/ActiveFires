import sys
import os
import csv
import json
from ftplib import FTP
from datetime import datetime, timedelta


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
    today = datetime.now()
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
    connection.cwd("FIRMS/Global")

    root_path = os.path.dirname(os.path.abspath(__file__))
    date_list = get_last_n_dates(n=1)
    satellite_fname = "Global_MCD14DL_{0}.txt"

    output = open(cfg.outfile, mode="w")
    output.write('[\n')

    for day in date_list:
        julian_date = calendar2julian(day)
        satellite_file = satellite_fname.format(julian_date)

        downloaded_fname = os.path.join(root_path,
                                        "{0}.csv".format(julian_date))
        download_file(connection, satellite_file, downloaded_fname)

        fieldnames = ("latitude", "longitude", "brightness", "scan", "track",
                      "acq_date", "acq_time", "satellite", "confidence", "version",
                      "bright_t31", "frp")
        downloaded_file = open(downloaded_fname, "r")
        reader = csv.DictReader(downloaded_file, fieldnames)
        row_list = list(reader)
        num_rows = len(row_list)

        for i in range(0, num_rows):
            if i == 0:
                continue
            json.dump(row_list[i], output)
            if i != num_rows - 1:
                output.write(",\n")
            else:
                output.write("\n")

        downloaded_file.close()
        os.remove(downloaded_fname)

    output.write("]")
    output.close()
    connection.close()


if __name__ == "__main__":
    main()