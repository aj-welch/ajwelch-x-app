import type { Configuration } from 'webpack';
import { merge } from 'webpack-merge';
import path from 'path';
import grafanaConfig, { Env } from './.config/webpack/webpack.config';

const config = async (env: Env): Promise<Configuration> => {
  const baseConfig = await grafanaConfig(env);

  return merge(baseConfig, {
    resolve: {
      alias: {
        // Workaround for grafana/scenes#1322
        // Forces both the plugin and @grafana/scenes to use the same @grafana/i18n instance
        // to avoid "t() was called before i18n was initialized" error
        '@grafana/i18n': path.resolve(__dirname, 'node_modules/@grafana/i18n'),
      },
    },
  });
};

export default config;
