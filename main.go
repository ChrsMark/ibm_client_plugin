package main

import (
	"github.com/elastic/beats/libbeat/beat"
	"github.com/elastic/beats/x-pack/metricbeat/module/ibmmq/util"
)

func CollectQmgrMetricset(a string, b string, c []byte) ([]beat.Event, error) {
	return util.CollectQmgrMetricset(a, b, c)
}
