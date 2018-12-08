#! /usr/bin/env expect

# Retrive arguments
set email [lindex $argv 0]
set host [lindex $argv 1]
set port [lindex $argv 2]
set sender [lindex $argv 3]

# Start a Telnet communication
spawn telnet $host $port;
send "helo hi\r"
expect "2?? *" {
} "5?? *" {
exit
} "4?? *" {
exit
} 

send "MAIL FROM: <$sender>\r"
expect "2.1.0 *" {
} "5?? *" {
exit
} "4?? *" {
exit
}

send "RCPT TO: <$email>\r"
expect "2?? *" {
} "5?? *" {
exit
} "4?? *" {
exit
}

send "QUIT\r"
exit