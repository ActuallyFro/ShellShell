#!/bin/bash
Version="0.0.1"
Name="template"
url="https://raw.githubusercontent.com/ActuallyFro/ShellShell/master/shellshell.sh"

read -d '' HelpMessage << EOF
<TOOL NAME>($Name) v$Version
==========================
TOOL DESCRIPTION

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

OType_1=$1
#IName_2=$2
#OName_3=$3

#WorkingDir=`echo $0 | sed 's/\/"$Name".sh//g'| sed 's/"$Name".sh//g'`
#if [[ "$WorkingDir" == "" ]]; then
#  WorkingDir=`which $Name`
#fi
#echo "[Debug] This is the location of $Name: $WorkingDir"

if [[ "$OType_1" == "--license" ]];then
   echo ""
   echo "$License"
   exit
fi

if [[ "$OType_1" == "--install" ]];then
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
fi

if [[ "$OType_1" == "--help" ]] || [[ "$OType_1" == "-h" ]];then
   echo ""
   echo "$HelpMessage"
   exit
fi

if [[ "$OType_1" == "--version" ]];then
   echo ""
   echo "Version: $Version"
   echo "md5 (less last line): "`cat $0 | grep -v "###" | md5sum | awk '{print $1}'`
   exit
fi

if [[ "$1" == "--update" ]];then
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
fi

### Current File MD5 (less this line): deed0a24e700de56807b980b51228c45
