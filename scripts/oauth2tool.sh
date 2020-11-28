#!/bin/dash

# based on oauth2token.sh of Joseph Harriott
#   (https://github.com/tenllado/dotfiles/tree/master/config/msmtp)

# argument: <Gmail username>

# initialization
#   (should be done before running the script for the first time)
#
#     user=<Gmail username>
#     client_id=<GoogleAPIClientID>
#     cleint_secret=<GoogleAPIClientSecret>
#     data_dir=/home/ashish/.local/share/gmail-oauth2/$user
#     oauth2=/home/ashish/.scripts/oauth2.py
#       (https://github.com/google/gmail-oauth2-tools/blob/master/python/oauth2.py)
#
#     current_time=$(date +%s)
#     mkdir -p "$data_dir"
#     output=(
#         $oauth2 \
#             --user="$user" \
#             --client_id=<GoogleAPIClientID> \
#             --client_secret=<GoogleAPIClientSecret> \
#             --generate_oauth2_token
#     )
#     newline='
#     '
#     output=${output#Refresh Token: }
#     refresh_token=${output%%${newline}*}
#     output=${output#*${newline}Access Token: }
#     access_token=${output%${newline}*}
#     expiry_time=${output#*${newline}Access Token Expiration Seconds: }
#     echo "$refresh_token" | pass insert -e "gmail-oauth2/$user/refresh_token"
#     echo "$client_id" >"$data_dir/client_id"
#     echo "$client_secret" >"$data_dir/client_secret"
#     echo "$access_token" >"$data_dir/access_token"
#     echo "$(( current_time + expiry_time - 60 ))" >"$data_dir/expiry_time"

user=$1
data_dir=/home/ashish/.local/share/gmail-oauth2/$user
ouath2=/home/ashish/.scripts/oauth2.py

get_access_token() {
    read -r client_id <"$data_dir/client_id"
    read -r client_secret <"$data_dir/client_secret"
    refresh_token=$(pass "gmail-oauth2/$user/refresh_token")
    output=$(
        $oauth2 \
            --user="$user" \
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

read -r expiry_time <"$data_dir/expiry_time"
current_time=$(date +%s)

if read -r access_token <"$data_dir/access_token" &&
   [ "$current_time" -lt "$expiry_time" ] ; then
    echo "$access_token"
else
    get_access_token
    echo "$access_token" >"$data_dir/access_token"
    echo "$(( current_time + expiry_time - 60 ))" >"$data_dir/expiry_time"
    echo "$access_token"
fi
