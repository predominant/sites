source ./plan.sh

@test "Service is running" {
  [ "$(hab svc status | grep "site-grahamweldon\.default" | awk '{print $4}' | grep up)" ]
}

@test "A single process" {
  result="$(ps aux | grep -v grep | grep -v "test\.bats" | grep site-grahamweldon | wc -l)"
  [ "${result}" -eq 1 ]
}

@test "Listening on port 8080 (HTTP)" {
  [ "$(netstat -peanut | grep caddy | awk '{print $4}' | awk -F':' '{print $2}' | grep 8080)" ]
}
