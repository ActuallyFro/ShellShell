#!/bin/bash
Version="1.1.0"
Name="shellshell"
url="https://raw.githubusercontent.com/ActuallyFro/ShellShell/master/shellshell.sh"

read -d '' HelpMessage << EOF
ShellShell ($Name) v$Version
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
--install - copy this script to /bin/($Name)
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
      cp $0 /bin/$Name
      Check=`ls /bin/$Name | wc -l`
      if [[ "$Check" == "1" ]]; then
         echo "$Name installed successfully!"
      fi
      exit
   ;;
   --version)
      echo ""
      echo "Version: $Version"
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
      wget $url -O /tmp/junk$ToolName
   elif [[ "`which curl`" != "" ]]; then
      echo "Grabbing latest GitHub commit...with curl...ew"
      curl $url > /tmp/junk$ToolName
   else
      echo "... or I cant; Install wget or curl"
   fi

   if [[ -f /tmp/junk$ToolName ]]; then
      lastVers="$Version"
      newVers=`cat /tmp/junk$ToolName | grep "Version=" | grep -v "cat" | tr "\"" "\n" | grep "\."`

      lastVersHack=`echo "$lastVers" | tr "." " " | awk '{printf("9%04d%04d%04d",$1,$2,$3)}'`
      newVersHack=`echo "$newVers" | tr "." " " | awk '{printf("9%04d%04d%04d",$1,$2,$3)}'`

      echo ""
      if [[ "$lastVersHack" -lt "$newVersHack" ]]; then
         echo "Updating $ToolName to $newVers"
         chmod +x /tmp/junk$ToolName

         echo "Checking the CRC..."
         CheckCRC=`/tmp/junk$ToolName --check-script | grep "good" | wc -l`

         if [[ "$CheckCRC" == "1" ]]; then
            echo "Installing ..."
            /tmp/junk$ToolName --install
         else
            echo "ERROR! The CRC failed, considering file to be bad!"
            rm /tmp/junk$ToolName
            exit
         fi
         rm /tmp/junk$ToolName
      else
         echo "You are up to date! ($lastVers)"
      fi
   else
      echo "Well ... that happened. (Check your Inet; the new $ToolName couldn't be grabbed!"
   fi
   exit
   ;;
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

### Current File MD5 (less this line): bf41fd5fefa387aa8477eb12a0918e9a
