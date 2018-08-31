#!/usr/bin/python

# Put this script in cron:
#   */30 6-23 * * * python <path>/check_schedule2.py
# change enableGV to False if you don't use or need Google Voice 
# This script will work with any college that uses Sungard's higher education crap
# Try not to hammer the system by checking every minute, every day ;)

# How to find your term and CRN numbers:
# - Log into Howdy/course portal. Add/Search for the course you're trying to get in
# - In the URL, you should see a part that says ?term=<numbers> - that is your term
#   (for example, 201131 is Fall '11)
# - The CRN for the course should be listed in the search results.
# - When a seat opens up, you can just use this number and add the course, without having
#   to go through all the search

import urllib, re, os.path
import urllib2
import sys
import logging
from time import strftime

# TODO Send notification with class title and course code
# TODO Read in from a configuration file

class College:
  name = ""
  basepath = ""
  term = ""
  crns = None

# ============
# SETTINGS 
# ============
# Google Voice settings
enableGV = False
phoneNumber = "1234567890"
login = "user@example.com"
pw = "password"

# Email settings
enableEmail = True
email = "CHANGEME@example.com"

colleges = list()
#collin = College()
#collin.name = "collin"
#collin.basepath = "https://ssb.collin.edu"
#collin.term = "201125"
#collin.crns = ["25005"]
#colleges.append(collin)

tamu = College()
tamu.name = "tamu"
tamu.basepath = "https://compass-ssb.tamu.edu"
tamu.term = "201131"
tamu.crns = ["23506"]
colleges.append(tamu)

# ============
# FUNCTIONS
# ============

logpath = "/tmp/schd2"

# FUNCTION: check CRNs
def check_seats( basepath, term, crn ):
  # FIXME hack
  if basepath.find("tamu") >= 0:
    urlpath = basepath+"/pls/PROD/bwykschd.p_disp_detail_sched?term_in=" +term+ "&crn_in=" +crn
  else:
    urlpath = basepath+"/pls/PROD/bwckschd.p_disp_detail_sched?term_in=" +term+ "&crn_in=" +crn
  print urlpath
  # try to connect to the site and make sure it exists
  try:
    urllib2.urlopen(urlpath, None, 5)
  except urllib2.URLError:
    print >> sys.stderr, "Timeout on " + urlpath
    return -1

  # open the connection
  conn = urllib.urlopen(urlpath)
  file = conn.read()
  open_seats = re.findall(r'TD CLASS="dddefault">(\d+)', file)
  if len(open_seats) < 3:
    print urlpath
    print >> sys.stderr, "Error on parsing.. Exiting"
    exit(1)
  return open_seats[2]

# FUNCTION: check log for previous open seats state
def check_log( log, id ):
  # Search the log for the crn
  results = re.findall(id+r' (\d+)', log)
  if len(results) == 0:
    return False
  else:
    return results[-1]

# Open the log file. Create one if it doesn't exist
newfile = False
if not os.path.exists(logpath):
  newfile = True
  open(logpath, 'w').close()
logfile = open(logpath, 'r+')
log = logfile.read()

for college in colleges:
  if college.term != "":
    for crn in college.crns:
      #with open(logpath, 'r+') as log:
      logFormat = college.name+":"+college.term+":"+crn
      prev_avail = check_log( log, logFormat )
    
      #logging.warn("test")  # change to info()
      # Logging: append time, college, tern, crn, only if there's a difference.
      print "Checking " + college.name + " with URL: ",
      seats_avail = check_seats( college.basepath, college.term, crn )
      print "CRN: " + crn
      if prev_avail != False:
        print "Seat count: " +prev_avail+ " since " + re.findall(r'([0-9-]+ [0-9:]+) ' +logFormat, log)[-1]
      print ""
      if seats_avail == -1:
        exit(1)
      if seats_avail != prev_avail:
        logfile.write(strftime("%Y-%m-%d %H:%M"))
        logfile.write(" " +logFormat+ " " +str(seats_avail)+ "\n")
        if prev_avail >= 0:
          # Notify the change
          msg = "Seats for CRN " +crn+ " has changed from " +str(prev_avail)+ " to " +str(seats_avail)
          if enableGV:
            from googlevoice import Voice
            from googlevoice.util import input
            voice = Voice()
            voice.login(login, pw)
            voice.send_sms(phoneNumber, msg)
          if enableEmail:
            os.system("echo " +msg+ " | mail " + email )
logfile.close()
