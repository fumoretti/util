# GROK patterns customizados

## SAMBA AUDIT LOGS

Sample log:

Sample 1

```
mycompany\user.name|10.1.1.100|MYHOST|myshare|unlink|ok|path/of/my/file/or/dir/right/here_mycompany_.indd
```

Match1

```json
^%{DATA:samba-domain}\\%{DATA:samba-user}\|%{IPV4:client-ip}\|%{DATA:client-hostname}\|%{DATA:samba-share}\|%{DATA:samba-operation}\|%{DATA:samba-oper-status}\|%{GREEDYDATA:samba-file-path}
```
Sample 2

```
2023/06/06 14:04:13 [WARN] agent: Check 'freenas_health' is now warning
```

Match 2

```json
"NASWARNTIME" => "(%{DATE} %{TIME})"
%{NASWARNTIME:@timestamp}%{SPACE}\[%{WORD:severity}\]%{SPACE}agent\:%{SPACE}%{GREEDYDATA:warning-event}
```

Logstash Filter:

```json
if "samba-audit" in [event.dataset] {
 
                grok{

                    break_on_match => "false"

                    pattern_definitions => { "NASWARNTIME" => "(%{DATE} %{TIME})" }

                    match => { "message" => "%{NASWARNTIME:@timestamp}%{SPACE}\[%{WORD:severity}\]%{SPACE}agent\:%{SPACE}%{GREEDYDATA:warning-event}"}

                    match => { "message" => "^%{DATA:samba-domain}\\%{DATA:samba-user}\|%{IPV4:client-ip}\|%{DATA:client-hostname}\|%{DATA:samba-share}\|%{DATA:samba-operation}\|%{DATA:samba-oper-status}\|%{GREEDYDATA:samba-file-path}" }
                                            
                    }
      }
```

## OpenEdge Progress DB logs

Samples 1

```
[2023/06/06@14:29:35.895-0300] P-976641     T-140037410675776 I ABL   107: (7129)  Usr 107 define nome para IMUSER.
```


Match 1

```json
%{GREEDYDATA:@timestamp}%{SPACE}\ P-%{INT:pid}\ %{SPACE}\ T-%{INT:openedge-transaction}%{SPACE}%{WORD:openedge-oper}%{SPACE}%{GREEDYDATA:openedge-protocol}\ %{SPACE}\ %{DATA:openedge-session}\:%{SPACE}\(%{GREEDYDATA:openedge-return-code}\)%{SPACE}%{GREEDYDATA:openedge-event}
```

Logstash:

```json
      if "openedge_logs" in [tags] {

                grok{
                        match => { "message" => "%{GREEDYDATA:@timestamp}%{SPACE}\ P-%{INT:pid}\ %{SPACE}\ T-%{INT:openedge-transaction}%{SPACE}%{WORD:openedge-oper}%{SPACE}%{GREEDYDATA:openedge-protocol}\ %{SPACE}\ %{DATA:openedge-session}\:%{SPACE}\(%{GREEDYDATA:openedge-return-code}\)%{SPACE}%{GREEDYDATA:openedge-event}" }
      }
   }
```

## GITEA golang logs


Sample 1


Match 1

```json
"GOLANGTIME" => "(%{DATE} %{TIME})"
%{GOLANGTIME:@timestamp} %{GREEDYDATA:gitea-event}
```

Logstash

```json
      if "gitea_logs" in [tags] {
 
                grok{
                      pattern_definitions => { "GOLANGTIME" => "(%{DATE} %{TIME})" }
                      match => { "message" => "%{GOLANGTIME:@timestamp} %{GREEDYDATA:gitea-event}" }
      }

   }
```


## CUPS print servers

Sample 1

```
localhost - - [06/Jun/2023:14:29:44 -0300] "POST /printers/myprinter HTTP/1.1" 200 712 Send-Document successful-ok
```

Match 1

```json
%{IPORHOST:clientip} - %{GREEDYDATA:usr} \[%{HTTPDATE:@timestamp}\] \"(?:%{WORD:method}%{SPACE}%{NOTSPACE:path}\/%{GREEDYDATA:cups-printer}%{SPACE}HTTP/%{NUMBER:httpversion}?|%{DATA:rawrequest})\" %{NUMBER:response} (?:%{NUMBER:bytes} %{GREEDYDATA:cups-event})
```

Sample 2

```
E [06/Jun/2023:14:29:07 -0300] [Client 24763] Returning IPP client-error-bad-request for Send-Document (ipp://localhost:631/printers/myprinter) from localhost.
```

Match 2

```
%{WORD:loglevel} \[%{HTTPDATE:@timestamp}\] %{GREEDYDATA:cups-event}
```

Logstash

```json
      if "cups_access" in [tags] {
 
                grok{
                        match => { "message" => "%{IPORHOST:clientip} - %{GREEDYDATA:usr} \[%{HTTPDATE:@timestamp}\] \"(?:%{WORD:method}%{SPACE}%{NOTSPACE:path}\/%{GREEDYDATA:cups-printer}%{SPACE}HTTP/%{NUMBER:httpversion}?|%{DATA:rawrequest})\" %{NUMBER:response} (?:%{NUMBER:bytes} %{GREEDYDATA:cups-event})" }
      }
   }

      if "cups_error" in [tags] {
 
                grok{
                        match => { "message" => "%{WORD:loglevel} \[%{HTTPDATE:@timestamp}\] %{GREEDYDATA:cups-event}" }
      }
   }
```

## FortiGAte Firewall

Filebeat Fortinet Module... 

### Ingest Topology:

Fortigate -> Filebeat Fortigate Module with Syslog Input -> Logstash with tags and event.dataset field based routes -> ElasticSearch -> Fortinet Module's ingest Pipelines.

### Simplified ingest pipeline

Based on stock fortinet ingest pipelines (filebeat-8.8.0-fortinet-firewall-pipeline and filebeat-8.8.0-fortinet-firewall-event) created by the filebeat module, but with some field drops do optimize index size. Basicaly, Cloned Stock pipeline (filebeat-8.8.0-fortinet-firewall-pipeline) and added fields to DELETE processor. All dropped fields:

```
"remove": {
      "field": [
        "_temp",
        "host",
        "syslog5424_sd",
        "syslog5424_pri",
        "fortinet.firewall.agent",
        "fortinet.firewall.date",
        "fortinet.firewall.devid",
        "fortinet.firewall.duration",
        "fortinet.firewall.eventtime",
        "fortinet.firewall.hostname",
        "fortinet.firewall.time",
        "fortinet.firewall.tz",
        "fortinet.firewall.url",
        "event.original",
        "agent.ephemeral_id",
        "agent.id",
        "agent.type",
        "agent.name",
        "destination.bytes",
        "destination.packets",
        "ecs.version",
        "event.category",
        "event.code",
        "event.duration",
        "event.ingested",
        "event.kind",
        "event.start",
        "event.timezone",
        "input.type",
        "log.level",
        "network.bytes",
        "network.community_id",
        "network.iana_number",
        "network.packets",
        "observer.vendor",
        "rule.category",
        "service.type",
        "source.bytes",
        "source.packets",
        "source.port",
        "tags",
        "event.action",
        "fileset.name",
        "source.mac",
        "log.source.address",
        "fortinet.firewall.vd",
        "fortinet.firewall.dstserver",
        "fortinet.firewall.srcserver",
        "fortinet.firewall.sessionid",
        "fortinet.firewall.dstmac",
        "rule.uuid",
        "event.module",
        "fortinet.firewall.trandisp",
        "observer.serial_number",
        "related.user",
        "rule.ruleset",
        "destination.as.number",
        "destination.as.organization.name",
        "destination.geo.continent_name",
        "destination.geo.country_iso_code",
        "destination.geo.country_name",
        "destination.geo.location",
        "fortinet.firewall.authserver"
      ]
}
```

Changed the name of pipelined called by the filebeat-8.8.0-fortinet-firewall-pipeline during processor to the cloned one.

From:
```
  {
    "pipeline": {
      "name": "filebeat-8.8.0-fortinet-firewall-event",
      "if": "ctx.fortinet?.firewall?.type == 'event'"
    }
  }
```
To:
```
  {
    "pipeline": {
      "name": "filebeat-optimized-fortinet-firewall-event",
      "if": "ctx.fortinet?.firewall?.type == 'event'"
    }
  }
```
### Logstash output route

```
  else if "fortinet" in  [@metadata][pipeline] {
    elasticsearch {
      hosts => "elasticsearch:9200"
      index => "fortinet-firewall"
      action => "create"
      pipeline => "filebeat-optimized-fortinet-firewall-pipeline"
      user => "filebeat_internal"
      password => "YOUR_FILEBEAT_INTERNAL_STRONG_PASSWORD_HERE"
    }
  }
```

## NGINX tcp/udp loadbalancer

sample access:
```
10.1.1.100 [2023-08-23T09:26:17-03:00] dns-lb01a UDP 10.1.1.105 200 10.1.1.110:53 0.000 172 44 0.000
```
nginx log_format:
```
log_format basic '$remote_addr [$time_iso8601] '
                 '$protocol $server_addr $status $upstream_addr $upstream_connect_time $bytes_sent $bytes_received '
                 '$session_time';
```
match:

```
^%{IP:source.ip}%{SPACE}\[%{TIMESTAMP_ISO8601:@timestamp}]%{SPACE}%{HOSTNAME:lb_host}%{SPACE}%{WORD:request_protocol}%{SPACE}%{IP:request_addr}%{SPACE}%{INT:request_response}%{SPACE}%{IP:upstream_addr}\:%{INT:request_port}%{SPACE}%{NUMBER:upstream_connect_time}%{SPACE}%{NUMBER:upstream_bytes_snd}%{SPACE}%{NUMBER:upstream_bytes_rcv}%{SPACE}%{NUMBER:upstream_session_time}
```

sample error:

```
2023/08/18 03:37:01 [error] 23#23: *5342 upstream timed out (110: Connection timed out) while proxying connection, udp client: 10.1.1.100, server: 0.0.0.0:53, upstream: "10.1.1.110:53", bytes from/to client:51/0, bytes from/to upstream:0/51
```

match:

```
^%{DATA:@timestamp}%{SPACE}\[%{WORD:nginx_loglevel}\]%{SPACE}%{INT:nginx_pid}\#%{INT:nginx_tid}\:%{SPACE}\*%{INT:nginx_cid}%{SPACE}%{GREEDYDATA:nginx_event}
```

## ORACLE DATABASE DIAG

### listener GROK

sample1: 

```
05-SEP-2023 10:38:22 * (CONNECT_DATA=(SID=MYDBSERVICE)(CID=(PROGRAM=)(HOST=__jdbc__)(USER=))) * (ADDRESS=(PROTOCOL=tcp)(HOST=192.168.1.100)(PORT=47536)) * establish * MYDBSERVICE * 0
```

sample2: 

```
06-SEP-2023 10:20:02 * (CONNECT_DATA=(SERVICE_NAME=MYDBSERVICE)(CID=(PROGRAM=sqlplus)(HOST=myapp.mycompany.com.br)(USER=clientuser))(CONNECTION_ID=BLGZ2CV8+zngYzQ3qMC9Ng==)) * (ADDRESS=(PROTOCOL=tcp)(HOST=192.168.2.221)(PORT=44264)) * establish * MYDBSERVICE * 0
```

sample3:

```
06-SEP-2023 15:46:48 * (CONNECT_DATA=(SERVICE_NAME=MYDB)) * (ADDRESS=(PROTOCOL=tcp)(HOST=192.168.1.100)(PORT=61167)) * establish * MYDB * 0
```

Match samples 1 and 2:

```
^%{DATA:@timestamp}%{SPACE}\*%{SPACE}\(CONNECT_DATA\=\(%{GREEDYDATA}(SERVICE_NAME|SID)=%{WORD:client_requested_service}\)\(CID\=\(PROGRAM=%{GREEDYDATA:client_program}\)\(HOST\=%{DATA:client_host}\)%{GREEDYDATA}\(USER\=%{DATA:client_user}\)%{GREEDYDATA}\(ADDRESS\=\(PROTOCOL\=%{DATA:client_protocol}\)\(HOST\=%{IP:client_ip}\)\(PORT\=%{INT:client_port}\)\)%{SPACE}\*%{SPACE}%{WORD:connection_status}%{SPACE}\*%{SPACE}%{WORD:oracle_service}
```

match 3:

```
^%{DATA:@timestamp}%{SPACE}\*%{SPACE}\(CONNECT_DATA\=\(%{GREEDYDATA}(SERVICE_NAME|SID)=%{WORD:client_requested_service}\)\)%{GREEDYDATA}\(ADDRESSo\=\(PROTOCOL\=%{DATA:client_protocol}\)\(HOST\=%{IP:client_ip}\)\(PORT\=%{INT:client_port}\)\)%{SPACE}\*%{SPACE}%{WORD:connection_status}%{SPACE}\*%{SPACE}%{WORD:oracle_service}
```

####  INGEST topology

Logstash:

Input:

Filebeat on Oracle Log files (added oradiag into tags field) to Logstash Beats Input.

Filter:

```
      if "oradiag" in [tags] {

                grok{
                      break_on_match => "true"
                      match => { "message" => "^%{DATA:@timestamp}%{SPACE}\*%{SPACE}\(CONNECT_DATA\=\(%{GREEDYDATA}(SERVICE_NAME|SID)=%{WORD:client_requested_service}\)\(CID\=\(PROGRAM=%{GREEDYDATA:client_program}\)\(HOST\=%{DATA:client_host}\)%{GREEDYDATA}\(USER\=%{DATA:client_user}\)%{GREEDYDATA}\(ADDRESS\=\(PROTOCOL\=%{DATA:client_protocol}\)\(HOST\=%{IP:client_ip}\)\(PORT\=%{INT:client_port}\)\)%{SPACE}\*%{SPACE}%{WORD:connection_status}%{SPACE}\*%{SPACE}%{WORD:oracle_service}" }
                      match => { "message" => "^%{DATA:@timestamp}%{SPACE}\*%{SPACE}\(CONNECT_DATA\=\(%{GREEDYDATA}(SERVICE_NAME|SID)=%{WORD:client_requested_service}\)\)%{GREEDYDATA}\(ADDRESS\=\(PROTOCOL\=%{DATA:client_protocol}\)\(HOST\=%{IP:client_ip}\)\(PORT\=%{INT:client_port}\)\)%{SPACE}\*%{SPACE}%{WORD:connection_status}%{SPACE}\*%{SPACE}%{WORD:oracle_service}" }
      }

                mutate { remove_field => [ "message" ] }
  }
```

Output:

```
  else if "oradiag" in [tags] and "_grokparsefailure" in [tags] {
    elasticsearch {
      hosts => "elasticsearch:9200"
      index => "filebeat-default"
      action => "create"
      user => "filebeat_internal"
      password => "YOURSTRONGFILEBEATPASSWORDHERE"
    }
  }

  else if "oradiag" in [tags] {
    elasticsearch {
      hosts => "elasticsearch:9200"
      index => "filebeat-oradiag"
      action => "create"
      user => "filebeat_internal"
      password => "YOURSTRONGFILEBEATPASSWORDHERE"
    }
  }
```

## Aruba Clearpass - Wifi Clientes

Sample:

```
<142>1 2023-09-29T14:26:42-03:00 clearpass cpass-guest - - [guest@14823 client="10.5.84.52:37628" server="10.199.1.235:443" script="/guest/guestssid.php" function="NwaGuestRegisterForm" args="array (
  'user' => 
  array (
    'id' => 378181,
    'username' => 'cliente1234@gmail.com',
    'password' => \"\\342\\227\\217\\342\\227\\217\\342\\227\\217\\342\\227\\217\\342\\227\\217\\342\\227\\217\\342\\227\\217\\342\\227\\217\",
    'start_time' => 1696008402,
    'expire_time' => 1696094802,
    'sponsor_name' => 'cliente1234@gmail.com',
    'sponsor_profile' => NULL,
    'enabled' => true,
    'current_state' => 'active',
    'notes' => NULL,
    'visitor_carrier' => NULL,
    'role_name' => NULL,
    'role_id' => 2,
    'mac' => 'AB-CD-EF-GH-IJ-03',
    'email' => 'cliente1234@gmail.com',
    'essid' => 'mycompany',
    'apname' => '0502',
    'cpf_id' => '99999999999',
    'source' => 'guestssid',
    'vcname' => 'LOJA_05',
    'apgroup' => '',
    'do_expire' => 1,
    'create_time' => 1696008372,
    'remote_addr' => '10.5.84.52',
    'visitor_name' => 'CLiente 1234',
    'expire_postlogin' => 0,
    'simultaneous_use' => 1,
  ),
)" details="array (
  'user' => 
  array (
  ),
)"] Updated user account cliente1234@gmail.com in the database
Account will expire at 2023-09-30 14:26:42
Account sponsor is cliente1234@gmail.com
User DB: ClearPass Policy Manager
```

### Fluxo do pipeline:

#### INPUT

```
syslog {
   port => 5618
   timezone => "America/Sao_Paulo"
   add_field => {
      "event.dataset" => "aruba-clearpass"
   }
}
```

#### FILTER

1. GROK que separa o array com informações do restante desnecessário em um field temporaria "clearpass_array"

```
grok { match => { "message" => "^\<(?m)%{GREEDYDATA}array\ \((?m)%{GREEDYDATA:clearpass_array}\,(?m)%{GREEDYDATA}\)\,(?m)%{GREEDYDATA}" } }
```

2. Mutate Filter que remove caracteres indesejaveis

```
mutate { 

   gsub => [

            "clearpass_array", "'", "",
            "clearpass_array", "\\n", ""
            
            ]
      }
```

3. KV filter em cima da field "clearpass_Array" separando CHAVE e VALORES baseado no separador "=>"

```
kv { source => "clearpass_array" field_split => "," value_split_pattern => "=>" trim_key => " " }
```

4. Conversão de data nas fields com padrão UNIX, ex:

```
date {

   match => [ "create_time","UNIX" ]
   target => "create_time"
   timezone => "America/Sao_Paulo"

}
```

5. Remove fields desnecessárias

```
mutate { remove_field => [ "clearpass_array", "message", "password" ] }
```

#### OUTPUT

Faz o ingest dos eventos no DAtaStream dedicado ao Aruba Clearpass, com rota ininicial para eventos com erro de matchgrok:

```
  else if "aruba-clearpass" in [event.dataset] and "_grokparsefailure" in [tags] {
   elasticsearch {
      hosts => "elasticsearch:9200"
      index => "filebeat-default"
      action => "create"
      user => "filebeat_internal"
      password => "SENHA"
   }
  }

  else if "aruba-clearpass" in [event.dataset] {
   elasticsearch {
      hosts => "elasticsearch:9200"
      index => "aruba-clearpass"
      action => "create"
      user => "filebeat_internal"
      password => "SENHA"
   }
  }
```