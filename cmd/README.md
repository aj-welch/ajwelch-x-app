# `/cmd`

Main Go applications for this project.

The directory name for each application should match the name of the executable
you want to have (e.g., `/cmd/myapp`).

Don't put a lot of code in the application directory. If you think the code can
be imported and used in other projects, then it should live in the `/pkg`
directory. If the code is not reusable or if you don't want others to reuse it,
put that code in the `/internal` directory. You'll be surprised what others will
do, so be explicit about your intentions!

It's common to have a small `main` function that imports and invokes the code
from the `/internal` and `/pkg` directories and nothing else.

Examples:

- <https://github.com/vmware-tanzu/velero/tree/fc0a16d7345e77610e9942b1f48985b336746f0b/cmd> (just a really small
  `main` function with everything else in packages)
- <https://github.com/moby/moby/tree/8dfa3a9c5e5c7f0cb27f5b2d3805c9b94922db99/cmd>
- <https://github.com/prometheus/prometheus/tree/ece9437624b4c75ee43b4b4794f5ecf426edf538/cmd>
- <https://github.com/influxdata/influxdb/tree/b3b982d746fdc34451ca44d262f83b483cd9ea33/cmd>
- <https://github.com/kubernetes/kubernetes/tree/4edf082c406416b170d923e8f2c2cee69d933ae6/cmd>
- <https://github.com/dapr/dapr/tree/2adc6ae91b7138d1c7567a2655083698451b9605/cmd>
- <https://github.com/ethereum/go-ethereum/tree/01fe1d716c0e2b22eca5d94bef37795843d70b9c/cmd>
