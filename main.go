package main

import (
	"context"
	"flag"
	"log"

	"git.ouroath.com/athenz/terraform_provider_athenz/athenz"
	"github.com/hashicorp/terraform-plugin-sdk/plugin"
)

func main() {

	var debugMode bool

	flag.BoolVar(&debugMode, "debug", false, "set to true to run the provider with support for debuggers like delve")
	flag.Parse()

	opts := &plugin.ServeOpts{ProviderFunc: athenz.Provider}

	if debugMode {
		err := plugin.Debug(context.Background(), "yahoo/provider/athenz", opts)
		if err != nil {
			log.Fatal(err.Error())
		}
		return
	}

	plugin.Serve(opts)
}
