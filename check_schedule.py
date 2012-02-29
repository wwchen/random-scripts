#!/usr/bin/python

import urllib, re, os.path
import urllib2
import sys
from googlevoice import Voice
from googlevoice.util import input

crn = "15113"
term = "201115"
# path
tamupath = "https://compass-ssb.tamu.edu"
collinpath = "https://ssb.collin.edu"

baseurlpath = "/pls/PROD/bwckschd.p_disp_detail_sched?term_in=" +term+ "&crn_in=" + crn
urlpath = collinpath + baseurlpath
logpath = "/tmp/schd"
# Google Voice settings
phoneNumber = "1234567890"
login = "user@example.com"
pw = "password"
msg = "Open seat found for CRN "  +crn+ "!"
# other settings
email = "user@example.com"

if not os.path.exists(logpath):
  open(logpath, 'w').close()
log = open(logpath, 'r+')

if(log.read() == "done"):
  print >> sys.stderr, "done"
  log.close()
  exit(0)

try:
  urllib2.urlopen(urlpath, None, 5)
except urllib2.URLError:
  print >> sys.stderr, "timeout on " + urlpath
  exit(1)
conn = urllib.urlopen(urlpath)
file = conn.read()
open_seats = re.findall(r'TD CLASS="dddefault">(\d+)', file)
if len(open_seats) != 6:
  print >> sys.stderr, "Error on parsing.. Exiting"
  print >> sys.stderr, "open_seats: ",
  print >> sys.stderr, open_seats
  exit(1)

if open_seats[2] != '0':
  msg += " Seats available: " + open_seats[2]
  voice = Voice()
  voice.login(login, pw)
  voice.send_sms(phoneNumber, msg)
  os.system("echo " +msg+ " | mail "+email)
  log.write("done")
  print >> sys.stderr, "Done. Seats available: " + open_seats[2]
else:
  print >> sys.stderr, "Not done. Seats available: " + open_seats[2]
  print >> sys.stderr, "open_seats: ",
  print >> sys.stderr, open_seats
