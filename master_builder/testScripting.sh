#!/bin/bash


# $1 is the device (ex /dev/disk2)
# $2 amount of cards to write
# $3 is the path to the public key used to connect to the nodes, this way we have secure passwordless ssh access out of the box
# if none is specified then defaults will be used
# by using [ $X ] && nomenclature, we force use of all three parameters if we want to use the last one, this removes room for error


# if first argument is present, then if -h or --help offer advice, and if it does not contain /dev/ then error and exit, otherwise carry on
# if first argument is not present, default values will be used for the target device: /dev/disk2
DEVICE="/dev/disk2"
DEVICE_NAME="disk2"
if [ $1 ];
  then 
    if [[ $1 == "-h" || $1 == "--help" ]];
      then echo -e " 
      This script installs DietPi OS to one or more SD cards\n 
      Usage: ./install2sdcard.sh TARGET_DEVICE NUMBER_OF_SDs PUBLIC_KEY_PATH

      Usage example: ./install2sdcard.sh /dev/disk2 1 ~/.ssh/id_edcsa.pub\n "; exit;
    fi
    if [[ $1 == *"/dev/"* ]];
      then
        DEVICE=$1 && DEVICE_NAME=$(echo $1 | cut -f3 -d'/');
      else
        echo -e "\n First argument must point to a device from /dev/!"; exit;
    fi
fi

# if $2 present, assign to QUANTITY
# default is 1
QUANTITY=1
[ $2 ] && if [[ $2 =~ ^[1-9]$ ]]; then QUANTITY=$2; else echo "Quantity must be a valid number between [1-9]";exit; fi
# if arg is present and the path points to a file containing a public key, then assign variable, otherwise 

# if first, second and third, args are present, in the third argument, if the path points to a file containing a public key, then assign variable, otherwise ask if user wants to exit or continue without public key added to sd card install
PUBLIC_KEY_PATH="none"
if [ $3 ];
  then if [[ $(file $3) == *"public key"* ]]; 
    then PUBLIC_KEY_PATH=$3; 
    else  
      read -p "The file in the path doesn't seem to be a public key, so it won't be added in the install process and you will have to add it later manually, do you want to exit? [Y/n]" -n 1 -r REPLY;
      if [[ $REPLY =~ ^[Yy]$ || -z $REPLY ]]; then exit; fi
    fi
fi

read -p $'\n\n'"Values to be used will be:
  
  Device: $DEVICE
  Quantity: $QUANTITY
  Public key path: $PUBLIC_KEY_PATH

  Proceed? [Y/n]
" -n 1 -r REPLY
if [[ $REPLY =~ ^[Nn]$ || ! -z $REPLY && ! $REPLY =~ ^[Yy]$ ]]; then exit; else echo -e "\nLet's do this..\n"; fi

if [[ $PUBLIC_KEY_PATH != "none" ]];
  then
    # replace path in automation script, @ as separator since we are working with paths -> /
    sed "s@<public_key>@$PUBLIC_KEY_PATH@" Automation_Custom_Script.sh;
fi
