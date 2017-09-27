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

  DbFileSize="$( stat -c %s "${FileDb}" )"
  echo "Db file size: $( StrBlocks "${DbFileSize}" )"

  FreeSpaceBefore="$(( $( stat -f --printf='%a * %s\n' / ) ))"
  echo "Free space before: $( StrBlocks "${FreeSpaceBefore}" )"

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
      echo "Removing db file '${FileDb}'" &&
      sudo rm -v "${FileDb}"
    }
  } &&
  {
    [ ! -e "${FileCronTask}" ] ||
    {
      echo "Removing db file '${FileCronTask}'" &&
      sudo rm -v "${FileCronTask}"
    }
  } &&
  true

  Res=$?

  FreeSpaceAfter="$(( $( stat -f --printf='%a * %s\n' / ) ))"
  echo "Free space after: $( StrBlocks "${FreeSpaceAfter}" )"

  RelesedSpace="$(( ${FreeSpaceAfter} - ${FreeSpaceBefore} ))"
  echo "Released space: $( StrBlocks "${RelesedSpace}" )"

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
