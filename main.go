package main

import (
	"github.com/elastic/beats/libbeat/beat"
	"github.com/ChrsMark/ibm_client_plugin/util"
)

func CollectQmgrMetricset(a string, b string, c []byte) ([]beat.Event, error) {
	return util.CollectQmgrMetricset(a, b, c)
}
