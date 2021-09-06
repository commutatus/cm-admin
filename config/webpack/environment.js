const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    moment: 'moment',
    Popper: ['popper.js', 'default']
  })
)

module.exports = environment
