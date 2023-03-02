#!/bin/bash

get_duration() {
  DUR="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 """$1""")"
  [ "$?" -ne 0 ] && DUR=0
  echo "$DUR" | cut -d. -f1
}

rsync -a /nextcloud/melvyndekort/files/InstantUpload/Camera/ /photos/melvyn/
rsync -a /nextcloud/kaatjeislief/files/InstantUpload/Camera/ /photos/karin/
rsync -a /nextcloud/daandekort/files/InstantUpload/Camera/ /photos/daan/

shopt -s globstar
for INPUT in /photos/**/*.mp4; do
  [[ "$INPUT" = *"-hevc.mp4" ]] && continue

  OUTPUT="$(echo $INPUT | sed 's/.mp4$/-hevc.mp4/')"

  if [ -f "$OUTPUT" ]; then
    INDUR="$(get_duration """$INPUT""")"
    OUTDUR="$(get_duration """$OUTPUT""")"

    case "$(($INDUR-$OUTDUR))" in
      -1) rm -f "$INPUT"; continue ;;
      0)  rm -f "$INPUT"; continue ;;
      1)  rm -f "$INPUT"; continue ;;
      *)  rm -f "$OUTPUT"; echo "WARN: $INPUT seemed to be incorrect, re-encoding" ;;
    esac
  fi

  echo "Starting conversion: $INPUT -> $OUTPUT"
  ffmpeg -i "$INPUT" -c:v libx265 -crf 26 -preset fast -c:a copy "$OUTPUT"
  [ "$?" -ne 0 ] && rm -f "$OUTPUT" && echo "Something went wrong" && exit 1
  touch -r "$INPUT" "$OUTPUT"

  INDUR="$(get_duration """$INPUT""")"
  OUTDUR="$(get_duration """$OUTPUT""")"
  case "$(($INDUR-$OUTDUR))" in
    -1) rm -f "$INPUT"; echo "Finished conversion: $INPUT -> $OUTPUT"; continue ;;
    0)  rm -f "$INPUT"; echo "Finished conversion: $INPUT -> $OUTPUT"; continue ;;
    1)  rm -f "$INPUT"; echo "Finished conversion: $INPUT -> $OUTPUT"; continue ;;
    *)  rm -f "$OUTPUT"; echo "ERROR: Something went wrong!"; exit 1 ;;
  esac
done
