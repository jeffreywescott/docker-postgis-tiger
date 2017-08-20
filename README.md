# jeffreywescott/postgis-tiger

The `jeffreywescott/postgis-tiger` image provides a Docker container running Postgres 9.6 with [PostGIS 2.3](http://postgis.net/) installed. This image is based on the [mdillon/postgis](https://hub.docker.com/r/mdillon/postgis/) image.

## Usage

### Run the Container

Use this command:

    docker run --name my-pg-tiger -e POSTGRES_PASSWORD=mysecretpassword -d jeffreywescott/postgis-tiger

### Downloading and Importing TIGER Data

First, you'll need to install the top-level nation data:

    docker exec -itu postgres my-pg-tiger /scripts/load-nation.sh

Then, you'll need to load any state-level data that you want:

    docker exec -itu postgres my-pg-tiger /scripts/load-states. CA IL NY   # space-separated

Loading the data takes a _really long time_. Be patient.

#### IMPORTANT: The `census.gov` IP Blacklist

If you try to load too many states all at once, [you'll probably have your IP address blacklisted](https://opendata.stackexchange.com/questions/10513/how-to-work-around-or-resolve-a-census-gov-ip-blacklist). So far, I have _not_ found a way to workaround getting blacklisted, or managed to get my own IP address off of the blacklist. :-(

## License

See the [LICENSE](./LICENSE) file.
