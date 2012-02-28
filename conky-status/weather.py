#!/usr/bin/python

import urllib2, re

def main(argv):
  loc = "KCLL"
  url = "http://www.weather.gov/xml/current_obs/" + loc + ".rss"
  content = urllib2.urlopen(url).read()
  # get the last title
  current = re.search('.*<title>(.*?) at.*</title>', content, flags=re.DOTALL).group(1).strip()
  current = re.sub(' and',',', current)
  print current


if __name__ == '__main__':
  import sys
  main(sys.argv)
