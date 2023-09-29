Transform Tunnels VPN versão 2


Informações base para o transform:

pattern:

*-fortinet*

Search: 

observer.name: MYFORTIFW* AND fortinet.firewall.action: (tunnel-down or tunnel-up or tunnel-stats) AND fortinet.firewall.tunnelip: *

Dest Index:

fortinet-vpn-tunnels

Frequency:

"frequency": "20s",
  "sync": {
    "time": {
      "field": "@timestamp",
      "delay": "10s"
    }

Group By:

fortinet.firewall.tunnelid
fortinet.firewall.tunnelip
destination.ip
source.user.name

Aggregations:

"tunnel.last.time": {
  "max": {
    "field": "@timestamp"
  }
},
"tunnel.first.time": {
  "min": {
    "field": "@timestamp"
  }
}


Para update:

POST _transform/<transform_id>/_update

Para review do transform:

POST _transform/_preview
{
  "id": "fortivpntunnels",
  "source": {
    "index": [
      "*-fortinet*"
    ],
    "query": {
      "bool": {
        "filter": [
          {
            "bool": {
              "filter": [
                {
                  "bool": {
                    "should": [
                      {
                        "wildcard": {
                          "observer.name": {
                            "value": "MYFORTIFW*"
                          }
                        }
                      }
                    ],
                    "minimum_should_match": 1
                  }
                },
                {
                  "bool": {
                    "should": [
                      {
                        "bool": {
                          "should": [
                            {
                              "term": {
                                "fortinet.firewall.action": {
                                  "value": "tunnel-down"
                                }
                              }
                            }
                          ],
                          "minimum_should_match": 1
                        }
                      },
                      {
                        "bool": {
                          "should": [
                            {
                              "term": {
                                "fortinet.firewall.action": {
                                  "value": "tunnel-up"
                                }
                              }
                            }
                          ],
                          "minimum_should_match": 1
                        }
                      },
                      {
                        "bool": {
                          "should": [
                            {
                              "term": {
                                "fortinet.firewall.action": {
                                  "value": "tunnel-stats"
                                }
                              }
                            }
                          ],
                          "minimum_should_match": 1
                        }
                      }
                    ],
                    "minimum_should_match": 1
                  }
                },
                {
                  "bool": {
                    "should": [
                      {
                        "exists": {
                          "field": "fortinet.firewall.tunnelip"
                        }
                      }
                    ],
                    "minimum_should_match": 1
                  }
                }
              ]
            }
          }
        ]
      }
    }
  },
  "dest": {
    "index": "fortinet-vpn-tunnels"
  },
  "frequency": "20s",
  "sync": {
    "time": {
      "field": "@timestamp",
      "delay": "10s"
    }
  },
  "pivot": {
    "group_by": {
      "tunnel.id": {
        "terms": {
          "field": "fortinet.firewall.tunnelid"
        }
      },
      "tunnel.ip": {
        "terms": {
          "field": "fortinet.firewall.tunnelip"
        }
      },
      "client.ip": {
        "terms": {
          "field": "destination.ip"
        }
      },
      "username": {
        "terms": {
          "field": "source.user.name"
        }
      }
    },
    "aggregations": {
      "tunnel.last.time": {
        "max": {
          "field": "@timestamp"
        }
      },
      "tunnel.first.time": {
        "min": {
          "field": "@timestamp"
        }
      }
    }
  },
  "description": "Processo de transformação que agrega em um indice informações de inicio e fim de conexões VPN baseado em eventos do fortinet.",
  "settings": {
    "num_failure_retries": -1
  },
  "retention_policy": {
    "time": {
      "field": "tunnel.first.time",
      "max_age": "30d"
    }
  }
}


Para criar:

POST _transform/
{
  "id": "fortivpntunnels",
  "source": {
    "index": [
      "*-fortinet*"
    ],
    "query": {
      "bool": {
        "filter": [
          {
            "bool": {
              "filter": [
                {
                  "bool": {
                    "should": [
                      {
                        "wildcard": {
                          "observer.name": {
                            "value": "MYFORTIFW*"
                          }
                        }
                      }
                    ],
                    "minimum_should_match": 1
                  }
                },
                {
                  "bool": {
                    "should": [
                      {
                        "bool": {
                          "should": [
                            {
                              "term": {
                                "fortinet.firewall.action": {
                                  "value": "tunnel-down"
                                }
                              }
                            }
                          ],
                          "minimum_should_match": 1
                        }
                      },
                      {
                        "bool": {
                          "should": [
                            {
                              "term": {
                                "fortinet.firewall.action": {
                                  "value": "tunnel-up"
                                }
                              }
                            }
                          ],
                          "minimum_should_match": 1
                        }
                      },
                      {
                        "bool": {
                          "should": [
                            {
                              "term": {
                                "fortinet.firewall.action": {
                                  "value": "tunnel-stats"
                                }
                              }
                            }
                          ],
                          "minimum_should_match": 1
                        }
                      }
                    ],
                    "minimum_should_match": 1
                  }
                },
                {
                  "bool": {
                    "should": [
                      {
                        "exists": {
                          "field": "fortinet.firewall.tunnelip"
                        }
                      }
                    ],
                    "minimum_should_match": 1
                  }
                }
              ]
            }
          }
        ]
      }
    }
  },
  "dest": {
    "index": "fortinet-vpn-tunnels"
  },
  "frequency": "20s",
  "sync": {
    "time": {
      "field": "@timestamp",
      "delay": "10s"
    }
  },
  "pivot": {
    "group_by": {
      "tunnel.id": {
        "terms": {
          "field": "fortinet.firewall.tunnelid"
        }
      },
      "tunnel.ip": {
        "terms": {
          "field": "fortinet.firewall.tunnelip"
        }
      },
      "client.ip": {
        "terms": {
          "field": "destination.ip"
        }
      },
      "username": {
        "terms": {
          "field": "source.user.name"
        }
      }
    },
    "aggregations": {
      "tunnel.last.time": {
        "max": {
          "field": "@timestamp"
        }
      },
      "tunnel.first.time": {
        "min": {
          "field": "@timestamp"
        }
      }
    }
  },
  "description": "Processo de transformação que agrega em um indice informações de inicio e fim de conexões VPN baseado em eventos do fortinet.",
  "settings": {
    "num_failure_retries": -1
  },
  "retention_policy": {
    "time": {
      "field": "tunnel.first.time",
      "max_age": "30d"
    }
  }
}


## Runtime field para calculo da duração do tunel VPN

PUT fortinet-vpn-tunnels/_mapping
{
    "runtime": {
      "tunnel.total.time": {
        "type": "keyword",
        "script": {
          "source": """
            def diffInSeconds = ( doc['tunnel.last.time'].value.getMillis() - doc['tunnel.first.time'].value.getMillis() ) / 1000 ;
            String s=String.valueOf(diffInSeconds % 60);
            String m=String.valueOf((diffInSeconds / 60) % 60) ;
            String h=String.valueOf((diffInSeconds / (60 * 60))) ;
            emit(h + 'h ' + m + 'm ' + s + 's') ;
          """
        }
      }
    }
}