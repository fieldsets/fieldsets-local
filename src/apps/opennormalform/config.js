module.exports = {
  siteTitle: 'Open Normal Form',
  siteShortTitle: 'ONF',
  siteDescription: 'Normalized Data Structure Abstraction',
  siteUrl: process.env.SITE_URL || 'https://normalform.org',
  siteIcon: './static/favicon.png',
  siteCompany: 'Open Normal Form',
  social: {
    Site: 'https://normalform.org',
    Blog: 'https://blog.normalform.org',
    GitHub: 'https://github.com/fieldsets',
    Twitter: 'https://twitter.com/opennormalform',
    Discord: 'https://discord.gg/',
    Port: 'https://port.normalform.org',
    Telegram: 'https://t.me/'
  },
  githubContentPath: 'https://github.com/opennormalform/docs/blob/main/content',
  redirects: [
    {
      from: '/concepts/',
      to: '/concepts/introduction/'
    },
    {
      from: '/tutorials/',
      to: '/tutorials/introduction/'
    },
    {
      from: '/references/',
      to: '/references/introduction/'
    },
    {
      from: '/concepts/wallets/',
      to: '/tutorials/wallets/'
    },
    {
      from: '/tutorials/get-ether-and-ocean-tokens/',
      to: '/concepts/get-ether-and-ocean-tokens/'
    },
    {
      from: '/tutorials/connect-to-networks/',
      to: '/concepts/connect-to-networks/'
    },
    {
      from: '/setup/compute-to-data/',
      to: '/tutorials/compute-to-data/'
    },
    {
      from: '/concepts/networks-overview/',
      to: '/concepts/networks/'
    },
    {
      from: '/concepts/network-ethmainnet/',
      to: '/concepts/networks/'
    },
    {
      from: '/concepts/network-rinkeby/',
      to: '/concepts/networks/'
    },
    {
      from: '/concepts/network-ropsten/',
      to: '/concepts/networks/'
    },
    {
      from: '/concepts/network-local/',
      to: '/concepts/networks/'
    },
    {
      from: '/concepts/connect-to-networks/',
      to: '/concepts/networks/'
    },
    {
      from: '/concepts/oeps-did/',
      to: '/concepts/did-ddo/'
    },
    {
      from: '/concepts/oeps-asset-ddo/',
      to: '/concepts/ddo-metadata/'
    },
    {
      from: '/tutorials/azure-for-brizo/',
      to: '/tutorials/azure-for-provider/'
    },
    {
      from: '/tutorials/amazon-s3-for-brizo/',
      to: '/tutorials/amazon-s3-for-provider/'
    },
    {
      from: '/tutorials/on-premise-for-brizo/',
      to: '/tutorials/on-premise-for-provider/'
    }
  ],
  swaggerComponents: []
}
