# ES-QL learning

Dissect example: KEEP only some dissected fields

```
ROW message = "Apr 09 07:43:22 pc NetworkManager[991]: <info>  [1712659402.9069] device (virbr0): state change: disconnected -> prepare (reason 'none')" | DISSECT message "%{+@timestamp} %{+@timestamp} %{+@timestamp} %{hostname} %{service}[%{pid}]: <%{level}>%{->} [%{message_unix_time}]%{->} device (%{eth_interface}): %{->}: %{eth_state_change} -> %{change_reason}" APPEND_SEPARATOR=" " | KEEP @timestamp,service,eth_interface,eth_state_change
```

output:

```json
{
  "@timestamp": "Apr 09 07:43:22",
  "service": "NetworkManager",
  "eth_interface": "virbr0",
  "eth_state_change": "disconnected"
}
```

Dissect example: EVAL source.ip and show as type ip

```
ROW message = "Apr 09 07:43:22 192.168.122.1 NetworkManager[991]: <info>  [1712659402906] device (virbr0): state change: disconnected -> prepare (reason 'none')" | DISSECT message "%{+@timestamp} %{+@timestamp} %{+@timestamp} %{source.ip} %{service}[%{pid}]: <%{level}>%{->} [%{message_unix_time}]%{->} device (%{eth_interface}): %{->}: %{eth_state_change} -> %{change_reason}" APPEND_SEPARATOR=" " | EVAL source.ip = to_ip(source.ip) |DROP message
```

output:

```json
{
  "@timestamp": "Apr 09 07:43:22",
  "service": "NetworkManager",
  "pid": "991",
  "level": "info",
  "message_unix_time": "1712659402906",
  "eth_interface": "virbr0",
  "eth_state_change": "disconnected",
  "change_reason": "prepare (reason 'none')",
  "source.ip": "192.168.122.1"
}
```