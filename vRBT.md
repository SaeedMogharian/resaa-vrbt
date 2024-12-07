shttp://hdx.resaa.net/newhdx.cgi?fe=1&lib=CEM0119J&v=03&tocLib=CEM0119J&tocV=03&id=EN%2dUS%5fTOPIC%5f0187454575&tocURL=resources%252ftoctopics%252fen%252dus%255ftopic%255f0187454575%252ehtml&p=t&ui=3&keyword=cat%2520as

http://hdx.resaa.net/newhdx.cgi?fe=1&lib=CEM0119J&v=03&tocLib=CEM0119J&tocV=03&id=EN%2dUS%5fTOPIC%5f0187454575&tocURL=resources%252ftoctopics%252fen%252dus%255ftopic%255f0187454575%252ehtml&p=t&ui=3&keyword=cat%2520as


---
The Video Ring Back Tone (VRBT) service is a customizeable service for a called party. It allows them to provide a fun, enjoyable, or entertaining video clip for callers to watch while the call is being connected. This service is an enhancement to audio RBT. It is designed for subscribers who want those that call them to have access to more exciting, personalized videos instead of ordinary RBTs.


### Dic:
- `AS`: Application Server
- `CESS`: Call Enhanced Supplementary Services
- `IFC`: Initial Filter Criteria
- `CAT`: Customized Alerting Tone

---
Kamailio Modules

UAC Module: https://www.kamailio.org/docs/modules/devel/modules/uac.html#idm34
Textopsx: https://www.kamailio.org/docs/modules/devel/modules/textopsx.html
Textops: https://kamailio.org/docs/modules/3.0.x/modules_k/textops.html
siptrace: https://www.kamailio.org/docs/modules/5.7.x/modules/siptrace.html
dialog: https://www.kamailio.org/docs/modules/devel/modules/dialog.html
mysql: https://www.kamailio.org/docs/modules/devel/modules/db_mysql.html#idm133
sdpops: https://www.kamailio.org/docs/modules/5.6.x/modules/sdpops.html#idm207
rtpengine: https://www.kamailio.org/docs/modules/5.4.x/modules/rtpengine.html#rtpengine.f.block_dtmf
crypto: https://www.kamailio.org/docs/modules/5.6.x/modules/crypto.html
TM: https://www.kamailio.org/docs/modules/devel/modules/tm.html#tm.f.t_send_reply

uac module example

---
### Sending Update Message on 180 reply (uac)
used help: https://nickvsnetworking.com/kamailio-bytes-sip-uac-module-to-act-as-a-uac-sip-client/

```c
loadmodule "uac.so"
...
modparam("rr", "append_fromtag", 1)
...
if(is_method("INVITE")){
	t_on_reply("UACTestUpdate");
}
...
onreply_route[UACTestUpdate] {
    if (status  == 180) {
	    # save becuase otherwise wont access!!
		$var(to_number) = $tU;
		
        xlog("UPDATE Notify Route\n");
        # Creating the sip headers
        $uac_req(method)="UDPATE";
        $uac_req(ruri)="sip:"+$si+":5060";
        $uac_req(furi)="sip:"+$fU+"@192.168.21.45";
        $uac_req(turi)="sip:"+$var(to_number)+"@192.168.21.45";
        $uac_req(callid)=$ci;
        $uac_req(hdrs)="Subject: Emergency Alert\r\n";
        $uac_req(hdrs)=$uac_req(hdrs) + "Content-Type: text/plain\r\n";
        $uac_req(body)="Emergency call from " + $fU + " on IP Address " + $si + " to " + $var(to_number) + "\n";
        $uac_req(evroute)=1;
		# send
        uac_req_send();
    }
}
```

### Save invite SDP in database (siptrace & mysql)
dp on siptrace: https://www.kamailio.org/docs/db-tables/kamailio-db-devel.html#idm7784
standard create: https://github.com/kamailio/kamailio/blob/master/utils/kamctl/mysql/standard-create.sql
table create in siptrace: https://github.com/kamailio/kamailio/blob/master/utils/kamctl/mysql/siptrace-create.sql


```docker-compose.yml
	db:  
    image: docker.resaa.net/library/mysql:8.0
    container_name: my_sql
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=passwd
    ports:
      - '3306:3306'
    volumes:
      - ./mysql:/var/lib/mysql
      - ./init-scripts:/docker-entrypoint-initdb.d

```

```sql
-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS rvrbt;
-- Use the created database
USE rvrbt;
-- Create version table
CREATE TABLE IF NOT EXISTS `version` (
    `id` INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL,
    `table_name` VARCHAR(32) NOT NULL,
    `table_version` INT UNSIGNED DEFAULT 0 NOT NULL,
    CONSTRAINT table_name_idx UNIQUE (`table_name`)
);
-- Insert initial version info for the version table
INSERT INTO version (table_name, table_version)
VALUES ('version', '1')
ON DUPLICATE KEY UPDATE table_version = '1';
-- Create sip_trace table
CREATE TABLE IF NOT EXISTS `sip_trace` (
    `id` INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL,
    `time_stamp` DATETIME DEFAULT '2000-01-01 00:00:01' NOT NULL,
    `time_us` INT UNSIGNED DEFAULT 0 NOT NULL,
    `callid` VARCHAR(255) DEFAULT '' NOT NULL,
    `traced_user` VARCHAR(255) DEFAULT '' NOT NULL,
    `msg` MEDIUMTEXT NOT NULL,
    `method` VARCHAR(50) DEFAULT '' NOT NULL,
    `status` VARCHAR(255) DEFAULT '' NOT NULL,
    `fromip` VARCHAR(64) DEFAULT '' NOT NULL,
    `toip` VARCHAR(64) DEFAULT '' NOT NULL,
    `fromtag` VARCHAR(128) DEFAULT '' NOT NULL,
    `totag` VARCHAR(128) DEFAULT '' NOT NULL,
    `direction` VARCHAR(4) DEFAULT '' NOT NULL
);

-- Create indexes for sip_trace table
CREATE INDEX IF NOT EXISTS traced_user_idx ON sip_trace (`traced_user`);
CREATE INDEX IF NOT EXISTS date_idx ON sip_trace (`time_stamp`);
CREATE INDEX IF NOT EXISTS fromip_idx ON sip_trace (`fromip`);
CREATE INDEX IF NOT EXISTS callid_idx ON sip_trace (`callid`);
-- Insert version info for the sip_trace table
INSERT INTO version (table_name, table_version)
VALUES ('sip_trace', '4')
ON DUPLICATE KEY UPDATE table_version = '4';
```


```bash
docker-compose up --build

docker exec -it my_sql mysql -u root -p # Enter password aferwards

# run the script in mysql
SOURCE /docker-entrypoint-initdb.d/init.sql;
```

```c
loadmodule "db_mysql.so"
...
modparam("siptrace", "db_url", "mysql://root:passwd@127.0.0.1:3306/rvrbt")
```

### RTPEngine

#### RTPEngine video support

Yes, **RTPengine** can handle video streams by acting as a proxy for RTP and other UDP-based media traffic, facilitating the routing and manipulation of both audio and video RTP data packets.[Sipwise](https://www.sipwise.com/archives/products/rtpengine?utm_source=chatgpt.com)
However, RTPengine's transcoding capabilities are currently limited to audio streams; it does not support video transcoding.[RTPengine Documentation](https://rtpengine.readthedocs.io/en/latest/transcoding.html?utm_source=chatgpt.com)

This means that while RTPengine can proxy video streams, it cannot perform operations such as changing video codecs or altering video formats.
Additionally, RTPengine offers a "Janus mode," allowing it to function as a drop-in replacement for the Janus WebRTC server in certain scenarios. This mode can lead to significantly lower CPU usage for WebRTC calls involving audio and video. [Sipwise](https://www.sipwise.com/archives/10995?utm_source=chatgpt.com)
In summary, RTPengine can proxy video streams effectively but lacks video transcoding capabilities. For applications requiring video transcoding, additional tools or services would be necessary.

#### rtpengine codec:
RTPengine supports a range of **audio** and **video** codecs, but its capabilities with respect to video codecs are somewhat more limited than those for audio. Here's an overview of the key codecs that RTPengine supports:

### **Audio Codecs Supported by RTPengine**:

1. **G.711 (A-law and μ-law)**
2. **G.722**
3. **Opus**
4. **G.729**
5. **G.723**
6. **iLBC**
7. **Speex**
8. **PCM (Raw audio)**

### **Video Codecs Supported by RTPengine**:

RTPengine supports the following video codecs:

1. **H.264** (most commonly used for video streaming and video calls)
2. **VP8** (a video codec commonly used in WebRTC)

However, RTPengine **does not support transcoding** for video streams, meaning it can proxy or route video streams (H.264 and VP8) between endpoints, but it cannot convert or change video formats (e.g., from VP8 to H.264). For instance, if two video endpoints use different video codecs (e.g., one uses H.264, and the other uses VP8), RTPengine can only route the streams, not convert between these codecs.

### **Important Limitations**:

- **No video transcoding**: RTPengine can’t transcode video (changing the video format or adjusting parameters like resolution or bitrate).
- **No support for newer codecs**: RTPengine doesn’t support newer video codecs like **HEVC/H.265** or **AV1** for media manipulation or transcoding.

### Summary:

- RTPengine supports **H.264** and **VP8** for video, but it cannot transcode between them.
- RTPengine is optimized for **audio** codecs and offers greater flexibility with audio-related tasks like transcoding, while video capabilities are mainly for routing and not modification.

If you need more complex video handling (e.g., transcoding or conversion between different video codecs), you'll likely need to use additional tools or services alongside RTPengine.