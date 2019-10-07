package commands

import (
	"fmt"
	"os"

	"github.com/docker/app/internal/store"
	"github.com/docker/cli/cli"
	"github.com/docker/cli/cli/command"
	"github.com/docker/cli/cli/config"
	"github.com/pkg/errors"
	"github.com/spf13/cobra"
)

func pullCmd(dockerCli command.Cli) *cobra.Command {
	cmd := &cobra.Command{
		Use:     "pull NAME:TAG [OPTIONS]",
		Short:   "Pull an application package from a registry",
		Example: `$ docker app pull docker/app-example:0.1.0`,
		Args:    cli.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return runPull(dockerCli, args[0])
		},
	}
	return cmd
}

func runPull(dockerCli command.Cli, name string) error {
	appstore, err := store.NewApplicationStore(config.Dir())
	if err != nil {
		return err
	}
	bundleStore, err := appstore.BundleStore()
	if err != nil {
		return err
	}

	bndl, ref, err := getLocalBundle(dockerCli, bundleStore, name, true)
	if err != nil {
		return errors.Wrap(err, name)
	}

	fmt.Fprintf(os.Stdout, "Successfully pulled %q (%s) from %s\n", bndl.Name, bndl.Version, ref.String())

	return nil
}
