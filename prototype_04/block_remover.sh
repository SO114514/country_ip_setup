#!/bin/bash

# Function to validate if the country code is a valid alpha-2 code
validate_country_code() {
  # List of all valid alpha-2 country codes
  local valid_codes=("AD" "AE" "AF" "AG" "AI" "AL" "AM" "AO" "AR" "AS" "AT" "AU" "AW" "AX" "AZ"
                     "BA" "BB" "BD" "BE" "BF" "BG" "BH" "BI" "BJ" "BL" "BM" "BN" "BO" "BQ" "BR"
                     "BS" "BT" "BV" "BW" "BY" "BZ" "CA" "CC" "CD" "CF" "CG" "CH" "CI" "CK" "CL"
                     "CM" "CN" "CO" "CR" "CU" "CV" "CW" "CX" "CY" "CZ" "DE" "DJ" "DK" "DM" "DO"
                     "DZ" "EC" "EE" "EG" "EH" "ER" "ES" "ET" "FI" "FJ" "FM" "FO" "FR" "GA" "GB"
                     "GD" "GE" "GF" "GG" "GH" "GI" "GL" "GM" "GN" "GP" "GQ" "GR" "GT" "GU" "GW"
                     "GY" "HK" "HM" "HN" "HR" "HT" "HU" "ID" "IE" "IL" "IM" "IN" "IO" "IQ" "IR"
                     "IS" "IT" "JE" "JM" "JO" "JP" "KE" "KG" "KH" "KI" "KM" "KN" "KP" "KR" "KW"
                     "KY" "KZ" "LA" "LB" "LC" "LI" "LK" "LR" "LS" "LT" "LU" "LV" "LY" "MA" "MC"
                     "MD" "ME" "MF" "MG" "MH" "MK" "ML" "MM" "MN" "MO" "MP" "MQ" "MR" "MS" "MT"
                     "MU" "MV" "MW" "MX" "MY" "MZ" "NA" "NC" "NE" "NF" "NG" "NI" "NL" "NO" "NP"
                     "NR" "NU" "NZ" "OM" "PA" "PE" "PF" "PG" "PH" "PK" "PL" "PM" "PN" "PR" "PT"
                     "PW" "PY" "QA" "RE" "RO" "RS" "RU" "RW" "SA" "SB" "SC" "SD" "SE" "SG" "SH"
                     "SI" "SJ" "SK" "SL" "SM" "SN" "SO" "SR" "SS" "ST" "SV" "SX" "SY" "SZ" "TC"
                     "TD" "TF" "TG" "TH" "TJ" "TK" "TL" "TM" "TN" "TO" "TR" "TT" "TV" "TZ" "UA"
                     "UG" "UM" "US" "UY" "UZ" "VA" "VC" "VE" "VG" "VI" "VN" "VU" "WF" "WS" "YE"
                     "YT" "ZA" "ZM" "ZW")
  
  # Check if the input country code is in the list of valid codes
  if [[ ! " ${valid_codes[@]} " =~ " ${COUNTRY} " ]]; then
    echo "無効な国コードです。再度入力してください。"
    exit 1
  fi
}

echo "国コードを入力してください (例: ID, JP):"
read COUNTRY

# Validate the country code
validate_country_code

# Delete the chain on iptables
echo "Iptables chain deletion has started..."
iptables -D INPUT -j DROP-${COUNTRY} > /dev/null 2>&1
iptables -F DROP-${COUNTRY} > /dev/null 2>&1
iptables -X DROP-${COUNTRY} > /dev/null 2>&1

# Show currently iptables list
iptables -nvxL

echo "iptables chain deletion complete."