#!/bin/bash
(
  _FuncBasic || exit 1

  ToolName='mlocate'
  AptPackageName='mlocate'
  echo "Removing '${ToolName}' ..."

  FileTool='/usr/bin/mlocate'
  FileToolLink='/usr/bin/locate'
  FileTool01='/usr/bin/updatedb.mlocate'
  FileDb='/var/lib/mlocate/mlocate.db'
  FileCronTask='/etc/cron.daily/mlocate'
  [ ! -e "${FileTool}" ] &&
  [ ! -e "${FileToolLink}" ] &&
  [ ! -e "${FileTool01}" ] &&
  [ ! -e "${FileDb}" ] &&
  [ ! -e "${FileCronTask}" ] &&
  echo 'Nothing to do' &&
  exit 0

  DbFileSize="$( stat -c %s "${FileDb}" )" &&
  DbFileSizePretty="$( StrBlocks "${DbFileSize}" )" &&
  echo "Db file size: ${DbFileSizePretty}" &&

  FreeSpaceBefore="$(( $( stat -f --printf='%a * %s\n' / ) ))" &&
  FreeSpaceBeforePretty="$( StrBlocks "${FreeSpaceBefore}" )" &&
  echo "Free space before: ${FreeSpaceBeforePretty}" &&

  {
    [ ! -e "${FileTool}" ] ||
    sudo apt remove "${AptPackageName}"
  } &&
  {
    [ ! -e "${FileTool01}" ] ||
    {
      echo "Tool file '${FileTool01}' was not removed."
      false
    }
  } &&
  {
    [ ! -e "${FileDb}" ] ||
    {
      echo "Removing file '${FileDb}'" &&
      sudo rm -v "${FileDb}"
    }
  } &&
  {
    [ ! -e "${FileCronTask}" ] ||
    {
      echo "Removing file '${FileCronTask}'" &&
      sudo rm -v "${FileCronTask}"
    }
  } &&
  true

  Res=$?

  FreeSpaceAfter="$(( $( stat -f --printf='%a * %s\n' / ) ))" &&
  FreeSpaceAfterPretty="$( StrBlocks "${FreeSpaceAfter}" )" &&
  echo "Free space after: ${FreeSpaceAfterPretty}" &&

  RelesedSpace="$(( ${FreeSpaceAfter} - ${FreeSpaceBefore} ))" &&
  RelesedSpacePretty="$( StrBlocks "${RelesedSpace}" )" &&
  echo "Released space: ${RelesedSpacePretty}" &&

  [ ! -e "${FileTool}" ] &&
  [ ! -e "${FileToolLink}" ] &&
  [ ! -e "${FileTool01}" ] &&
  [ ! -e "${FileDb}" ] &&
  [ ! -e "${FileCronTask}" ] &&
  echo "Removed all files." ||
  {
    echo "Error: At least one file left."
    Res=1
  }

  ( exit $Res )
)
