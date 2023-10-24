#!/usr/bin/env python3

import logging

from nextcloud_sync import nextcloud_sync
from processor import processor

def main(target):
  logging.basicConfig(level=logging.INFO)

  nextcloud_sync.main(target)
  processor.main(target)

if __name__ == '__main__':
  main('/target')
