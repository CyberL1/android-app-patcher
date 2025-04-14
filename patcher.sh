#!/bin/bash

# Varables

BASE_DIR=$(pwd)

TOOLS_DIR="$BASE_DIR/tools"
PATCHES_DIR="$BASE_DIR/patches"
APKS_DIR="$BASE_DIR/apks"
PATCHED_APKS_DIR="$BASE_DIR/patched-apks"
TMP_DIR="$BASE_DIR/tmp"
APK_SOURCES_DIR="$TMP_DIR/sources"

function init() {
  if test ! -d $TOOLS_DIR; then
    echo "Tools directory not found, creating"
    mkdir $TOOLS_DIR
  fi

  if test ! -f $TOOLS_DIR/apktool.jar; then
    echo "apktool.jar not found, downloading"
    wget -O $TOOLS_DIR/apktool.jar https://github.com/iBotPeaches/Apktool/releases/download/v2.11.1/apktool_2.11.1.jar
  fi

  if test ! -f $TOOLS_DIR/uber-apk-signer.jar; then
    echo "uber-apk-signer.jar not found, downloading"
    wget -O $TOOLS_DIR/uber-apk-signer.jar https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar
  fi

  if test ! -d $PATCHES_DIR; then
    echo "Patches directory not found, creating"
    mkdir $PATCHES_DIR
  fi

  if test ! -d $APKS_DIR; then
    echo "Apks directory not found, creating"
    mkdir $APKS_DIR
  fi

  if test ! -d $PATCHED_APKS_DIR; then
    echo "Patched APKs directory not found, creating"
    mkdir $PATCHED_APKS_DIR
  fi

  if test ! -d $TMP_DIR; then
    echo "Tmp directory not found, creating"
    mkdir $TMP_DIR
  fi

  if test ! -d $APK_SOURCES_DIR; then
    echo "APK sources directory not found, creating"
    mkdir $APK_SOURCES_DIR
  fi

  # Command handler

  if test $1; then
    command_$1 $@
  else
    command_help
  fi
}

# Commands

function command_help() {
  echo "Usage: $0 <command>"
  echo "Commands:"
  echo "  help - Show this help message"
  echo "  decompile - Decompile an app"
  echo "  generate - Generate a patch for an app"
}

function command_decompile() {
  APP_NAME=$2
  if test ! $APP_NAME; then
    echo "Usage: $0 decompile <app>"
    exit 1
  fi

  if test ! -d $APK_SOURCES_DIR/$APP_NAME; then
    echo "APK sources directory for $APP_NAME not found, creating"
    mkdir $APK_SOURCES_DIR/$APP_NAME
  fi

  if test ! -f $APKS_DIR/$APP_NAME.apk; then
    echo "APK for $APP_NAME not found"
    exit 1
  fi

  echo "Decompiling $APP_NAME"
  java -jar $TOOLS_DIR/apktool.jar d $APKS_DIR/$APP_NAME.apk -o $APK_SOURCES_DIR/$APP_NAME -f
}

function command_generate() {
  APP_NAME=$2
  if test ! $APP_NAME; then
    echo "Usage: $0 generate <app> <original_file_path> <patch_name>"
    exit 1
  fi

  ORIGINAL_FILE_PATH=$3
  if test ! $ORIGINAL_FILE_PATH; then
    echo "Usage: $0 generate <app> <original_file_path> <patch_name>"
    exit 1
  fi

  PATCH_NAME=$4
  if test ! $PATCH_NAME; then
    echo "Usage: $0 generate <app> <original_file_path> <patch_name>"
    exit 1
  fi
 
  if test ! -d $PATCHES_DIR/$APP_NAME; then
    echo "Patches directory for $APP_NAME not found, creating"
    mkdir $PATCHES_DIR/$APP_NAME
  fi

  if test ! -f $APKS_DIR/$APP_NAME.apk; then
    echo "APK for $APP_NAME not found"
    exit 1
  fi

  echo "Generating $PATCH_NAME patch for $APP_NAME"
  diff -u $ORIGINAL_FILE_PATH $ORIGINAL_FILE_PATH.modified > $PATCHES_DIR/$APP_NAME/$PATCH_NAME.patch
}

# Initialize the script
init $@
