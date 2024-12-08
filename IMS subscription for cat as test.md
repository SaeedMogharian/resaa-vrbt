432011235813210
554312318532110
ims.mnc011.mcc432.3gppnetwork.org
sip:011235813213455@ims.mnc011.mcc432.3gppnetwork.org
tel:554312318532110
sip:554312318532110@ims.mnc011.mcc432.3gppnetwork.org

432011235813211

554312318532111
sip:011235813213456@ims.mnc011.mcc432.3gppnetwork.org

#### 20. Add IMS subscription use in FoHSS as follows from the Web GUI

Assuming IMSI of the user as 001010123456791 and MSISDN is 0198765432100


Login to the HSS web console.
Navigate to the User Identities page
Create the IMSU 
Click IMS Subscription / Create
Enter:
Name = 001010123456791
Capabilities Set = cap_set1
Preferred S-CSCF = scsf1
Click Save

Create the IMPI and Associate the IMPI to the IMSU
Click Create & Bind new IMPI
Enter:
Identity = 001010123456791@ims.mnc001.mcc001.3gppnetwork.org
Secret Key = 8baf473f2f8fd09487cccbd7097c6862 (Ki value as in Open5GS HSS database)
Authentication Schemes - All
Default = Digest-AKAv1-MD5
AMF = 8000 (As in Open5GS HSS database)
OP = 11111111111111111111111111111111 (As in Open5GS HSS database)
SQN = 000000021090 (SQN value as in Open5GS HSS database)
Click Save

Create and Associate IMPI to IMPU
Click Create & Bind new IMPU
Enter:
Identity = sip:001010123456791@ims.mnc001.mcc001.3gppnetwork.org
Barring = Yes
Service Profile = default_sp
Charging-Info Set = default_charging_set
IMPU Type = Public_User_Identity
Click Save

Add Visited Network to IMPU
Enter:
Visited Network = ims.mnc001.mcc001.3gppnetwork.org
Click Add

Now, goto Public User Identity and create further IMPUs as following

1. tel:0198765432100

Public User Identity -IMPU-
Identity = tel:0198765432100
Service Profile = default_sp
Charging-Info Set = default_charging_set
Can Register = Yes
IMPU Type = Public_User_Identity
Click Save

Add Visited Network to IMPU
Enter:
Visited Network = ims.mnc001.mcc001.3gppnetwork.org
Click Add

Associate IMPI(s) to IMPU
IMPI Identity = 001010123456791@ims.mnc001.mcc001.3gppnetwork.org
Click Add

2. sip:0198765432100@ims.mnc001.mcc001.3gppnetwork.org

Public User Identity -IMPU-
Identity = sip:0198765432100@ims.mnc001.mcc001.3gppnetwork.org
Service Profile = default_sp
Charging-Info Set = default_charging_set
Can Register = Yes
IMPU Type = Public_User_Identity
Click Save

Add Visited Network to IMPU
Enter:
Visited Network = ims.mnc001.mcc001.3gppnetwork.org
Click Add

Associate IMPI(s) to IMPU
IMPI Identity = 001010123456791@ims.mnc001.mcc001.3gppnetwork.org
Click Add

And, finally add these IMPUs as implicit set of IMSI derived IMPU in HSS i.e sip:001010123456791@ims.mnc001.mcc001.3gppnetwork.org as follows:

1. Goto to IMPU sip:001010123456791@ims.mnc001.mcc001.3gppnetwork.org
2. In "Add IMPU(s) to Implicit-Set" section give IMPU Identity created above to be added to this IMPU