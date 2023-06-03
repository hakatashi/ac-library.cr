filename="$1"; shift
output="$1"; shift

if [ "$filename" -nt "${output}" ]; then
  echo "Building Crystal project ${filename}..."
  if [ -d /usr/local/share/crystal-0.33.0-1 ]; then
    /usr/local/share/crystal-0.33.0-1/bin/crystal build "$filename" -o "${output}" --error-trace $@ || exit 1
  elif [ -d /tmp/crystal-0.33.0-1 ]; then
    /tmp/crystal-0.33.0-1/bin/crystal build "$filename" -o "${output}" --error-trace $@ || exit 1
  elif [[ "`crystal version`" == *"0.33.0"* ]]; then
    crystal build "$filename" -o "${output}" --error-trace $@ || exit 1
  elif [ -d /usr/local/share/crystal-1.7.3 ]; then
    /usr/local/share/crystal-1.7.3/bin/crystal build "$filename" -o "${output}" --error-trace $@ || exit 1
  elif [ -d /tmp/crystal-1.7.3 ]; then
    /tmp/crystal-1.7.3/bin/crystal build "$filename" -o "${output}" --error-trace $@ || exit 1
  elif [[ "`crystal version`" == *"1.7.3"* ]]; then
    crystal build "$filename" -o "${output}" --error-trace $@ || exit 1
  else
    docker run -v "$PWD":/mnt crystallang/crystal:0.33.0 crystal build "/mnt/$filename" -o "/mnt/${output}" --error-trace $@ || exit 1
  fi
fi

echo "Build completed."