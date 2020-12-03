#!/bin/dash

# adapted from:
#     oauth2token.sh - Joseph Harriott
#     https://github.com/harriott/ArchBuilds/blob/master/jo/mail/oauth2tool.sh
#
#
# initialize:
#   (before running the script for the first time)
#
#     user=<gmail username>
#     client_id=<oauth2 client id>
#     cleint_secret=<oauth2 client secret>
#     data_dir=/home/ashish/.local/share/gmail-oauth2/$user
#     oauth2_script=/home/ashish/.scripts/oauth2.py
#
#     mkdir -p "$data_dir"
#     current_time=$(date +%s)
#     $oauth2_script \
#         --client_id="$client_id" \
#         --client_secret="$client_secret" \
#         --generate_oauth2_token
#     refresh_token=<refresh token from output of oauth2_script>
#     access_token=<access token from output of oauth2_script>
#     expiry_time=<access token expiry time from output of oauth_script>
#     echo "$client_id" >"$data_dir/client_id"
#     echo "$client_secret" >"$data_dir/client_secret"
#     echo "$refresh_token" | pass insert -e "gmail-oauth2/$user/refresh_token"
#     echo "$access_token" >"$data_dir/access_token"
#     echo "$(( current_time + expiry_time - 60 ))" >"$data_dir/expiry_time"
#
#
# reset access token:
#   (in case access token got corrupted)
#
#     user=<gmail username>
#     data_dir=/home/ashish/.local/share/gmail-oauth2/$user
#
#     date +%s >"$data_dir/expiry_time"

user=$1
data_dir=/home/ashish/.local/share/gmail-oauth2/$user

get_access_token() {
    oauth2_script=/home/ashish/.scripts/oauth2.py

    read -r client_id <"$data_dir/client_id"
    read -r client_secret <"$data_dir/client_secret"
    refresh_token=$(pass "gmail-oauth2/$user/refresh_token")
    output=$(
        $oauth2_script \
            --client_id="$client_id" \
            --client_secret="$client_secret" \
            --refresh_token="$refresh_token"
    )
    newline='
'
    output=${output#Access Token: }
    access_token=${output%${newline}*}
    expiry_time=${output#*${newline}Access Token Expiration Seconds: }
}

read -r access_token <"$data_dir/access_token"
read -r expiry_time <"$data_dir/expiry_time"
current_time=$(date +%s)

if [ "$current_time" -lt "$expiry_time" ] ; then
    echo "$access_token"
else
    get_access_token
    echo "$access_token" >"$data_dir/access_token"
    echo "$(( current_time + expiry_time - 60 ))" >"$data_dir/expiry_time"
    echo "$access_token"
fi
