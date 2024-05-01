# ES-QL learning

Dissect example 1:

ROW message = "Apr 09 07:43:22 pc NetworkManager[991]: <info>  [1712659402.9069] device (virbr0): state change: disconnected -> prepare (reason 'none')" | DISSECT message "%{+@timestamp} %{+@timestamp} %{+@timestamp} %{hostname} %{service}[%{pid}]: <%{level}>%{->} [%{message_unix_time}]%{->} device (%{eth_interface}): %{->}: %{eth_state_change} -> %{change_reason}" APPEND_SEPARATOR=" " | KEEP @timestamp,service,eth_interface,eth_state_change

output:

{
  "@timestamp": "Apr 09 07:43:22",
  "service": "NetworkManager",
  "eth_interface": "virbr0",
  "eth_state_change": "disconnected"
}