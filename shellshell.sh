#!/bin/bash
ProgVersion="1.1.1"
ProgName="shellshell"
ProgUrl="https://raw.githubusercontent.com/ActuallyFro/ShellShell/master/shellshell.sh"

read -d '' HelpMessage << EOF
ShellShell ($ProgName) v$ProgVersion
==============================
This script can be leveraged as a simple script starter having basic features.
These features include the printing of a help message, license, printing of the
current version, and 'updating' of the shell from an online resource.
It's left to the developer to hodgepodge their code with this script.

Options
-------
Describe and list as such...

Other Options
-------------
--license - print license
--version - print version number
--install - copy this script to /bin/($ProgName)
--update  - update to the most recent GitHub commit
EOF

read -d '' License << EOF
Copyright (c) 2016 Brandon Froberg

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF

while [[ $# -gt 0 ]]; do
   parsearg="$1" #read in the first argument

   case $parsearg in
   #-----------------------------------#
   ## EXAMPLE COMMANDS -- START ##
   -e|--example)
      EXVAR="$2"
      shift #needs to skip var, since its NOT a flag
   ;;
   -v|-d|--debug)
      DEBUG=YES
   ;;
   ## EXAMPLE COMMANDS -- END ##
   #-----------------------------------#
   --license)
      echo ""
      echo "$License"
      exit
   ;;
   -h|--help)
      echo ""
      echo "$HelpMessage"
      exit
   ;;
   -i|--install)
      echo ""
      echo "Attempting to install $0 to /bin"

      User=`whoami`
      if [[ "$User" != "root" ]]; then
         echo "[WARNING] Currently NOT root!"
      fi
      cp $0 /bin/$ProgName
      Check=`ls /bin/$ProgName | wc -l`
      if [[ "$Check" == "1" ]]; then
         echo "$ProgName installed successfully!"
      fi
      exit
   ;;
   --version)
      echo ""
      echo "Version: $ProgVersion"
      echo "md5 (less last line): "`cat $0 | grep -v "###" | md5sum | awk '{print $1}'`
      exit
   ;;
   --crc|--check-script)
      CRCRan=`$0 --version | grep "md5" | tr ":" "\n" | grep -v "md5" | tr -d " "`
      CRCScript=`tail -1 $0 | grep -v "md5sum" | grep -v "cat" | tr ":" "\n" | grep -v "md5" | tr -d " " | grep -v "#"`
      if [[ "$CRCRan" == "$CRCScript" ]]; then
         echo "$0 is good!"
      else
         echo "The checksums didn't match!"
         echo "1. $CRCRan  (vs.)"
         echo "2. $CRCScript"
      fi
      exit
   ;;
   -u|--update)
   echo ""
   if [[ "`which wget`" != "" ]]; then
      echo "Grabbing latest GitHub commit..."
      wget $ProgUrl -O /tmp/junk$ProgName
   elif [[ "`which curl`" != "" ]]; then
      echo "Grabbing latest GitHub commit...with curl...ew"
      curl $ProgUrl > /tmp/junk$ProgName
   else
      echo "... or I cant; Install wget or curl"
   fi

   if [[ -f /tmp/junk$ProgName ]]; then
      lastVers="$ProgVersion"
      newVers=`cat /tmp/junk$ProgName | grep "Version=" | grep -v "cat" | tr "\"" "\n" | grep "\."`

      lastVersHack=`echo "$lastVers" | tr "." " " | awk '{printf("9%04d%04d%04d",$1,$2,$3)}'`
      newVersHack=`echo "$newVers" | tr "." " " | awk '{printf("9%04d%04d%04d",$1,$2,$3)}'`

      echo ""
      if [[ "$lastVersHack" -lt "$newVersHack" ]]; then
         echo "Updating $ProgName to $newVers"
         chmod +x /tmp/junk$ProgName

         echo "Checking the CRC..."
         CheckCRC=`/tmp/junk$ProgName --check-script | grep "good" | wc -l`

         if [[ "$CheckCRC" == "1" ]]; then
            echo "Installing ..."
            /tmp/junk$ProgName --install
         else
            echo "ERROR! The CRC failed, considering file to be bad!"
            rm /tmp/junk$ProgName
            exit
         fi
         rm /tmp/junk$ProgName
      else
         echo "You are up to date! ($lastVers)"
      fi
   else
      echo "Well ... that happened. (Check your Inet; the new $ProgName couldn't be grabbed!"
   fi
   exit
   ;;
   *)
      #The catch all; Throw warnings or don't...
      echo "[WARNING] Option: $1 -- NOT RECOGNIZED!"
   ;;
   esac

   shift #check next parsed arg
done

###########################################################
# Main Program Goes here; parsing of variables is completed
###########################################################

### Current File MD5 (less this line): b94fb36e19015d6683aff601b5cf99a7
