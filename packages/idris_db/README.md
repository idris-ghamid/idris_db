<p align="center">
  <a href="https://github.com/idris-ghamid/idris_db">
    <img src="../../assets/logo.png" width="160">
  </a>
  <h1 align="center">IdrisDb Plus Database</h1>
</p>

<p align="center">
  <a href="https://pub.dev/packages/idris_db"><img src="https://img.shields.io/pub/v/idris_db?label=pub.dev&labelColor=333940&logo=dart"></a>
  <a href="https://pub.dev/packages/idris_db/score"><img src="https://img.shields.io/pub/points/idris_db?label=score&labelColor=333940&logo=dart"></a>
  <a href="https://app.codecov.io/gh/idris-ghamid/idris_db"><img src="https://img.shields.io/codecov/c/github/idris-ghamid/idris_db?logo=codecov&logoColor=fff&labelColor=333940"></a>
  <a href="https://github.com/idris-ghamid/idris_db"><img src="https://img.shields.io/github/stars/idris-ghamid/idris_db?style=social"></a>
</p>

<p align="center">
  <a href="https://buymeacoffee.com/ahmtydn">
    <img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee">
  </a>
</p>

---

## About IdrisDb Plus

IdrisDb Plus is an enhanced fork of the original [IdrisDb database](https://github.com/IdrisDb/IdrisDb) created by Simon Choi. This project builds upon the solid foundation of the original IdrisDb, adding new features, improvements, and ongoing maintenance.

### What's Different?

- ✨ **Enhanced Features**: Additional capabilities beyond the original IdrisDb
- 🌐 **Improved Web Support**: Better SQLite/WASM integration for Flutter Web
- 🔧 **Active Maintenance**: Regular updates and bug fixes
- 🚀 **Performance Optimizations**: Continuous improvements to speed and efficiency

## Features

- 💙 **Made for Flutter**. Easy to use, no config, no boilerplate
- 🚀 **Highly scalable** The sky is the limit (pun intended)
- 🍭 **Feature rich**. Composite & multi-entry indexes, query modifiers, JSON support etc.
- ⏱ **Asynchronous**. Parallel query operations & multi-isolate support by default
- 🦄 **Open source**. Everything is open source and free forever!
- ✨ **Enhanced**. Additional features and improvements over the original IdrisDb
- 🌐 **Persistent web storage**. IndexedDB for Flutter Web.

## Documentation

📚 **Comprehensive documentation is available at [idris-db-docs.vercel.app](https://idris-db-docs.vercel.app/)**

<p align="center">
  <img src="../../.github/assets/IDRISDB_docs.png" alt="IdrisDb Plus Documentation" width="600">
</p>

Join the [Telegram group](https://t.me/IDRISDBplus) for discussion and sneak peeks of new versions of the DB.

If you want to say thank you, star us on GitHub and like us on pub.dev 🙌💙

## IdrisDb Database Inspector

The IdrisDb Inspector allows you to inspect the IdrisDb instances & collections of your app in real-time. You can execute queries, edit properties, switch between instances and sort the data.

<img src="../../.github/assets/inspector.gif" width="100%">

To launch the inspector, just run your IdrisDb app in debug mode and open the Inspector link in the logs.


## Benchmarks

Benchmarks only give a rough idea of the performance of a database but as you can see, IdrisDb NoSQL database is quite fast 😇

| <img src="../../.github/assets/benchmarks/insert.png" width="100%" /> | <img src="../../.github/assets/benchmarks/query.png" width="100%" /> |
| ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| <img src="../../.github/assets/benchmarks/update.png" width="100%" /> | <img src="../../.github/assets/benchmarks/size.png" width="100%" />  |

If you are interested in more benchmarks or want to check how IdrisDb performs on your device you can run the [benchmarks](https://github.com/IdrisDb/IDRISDB_benchmark) yourself.

## Unit tests

If you want to use IdrisDb database in unit tests or Dart code, call `await IdrisDb.initializeIDRISDBCore(download: true)` before using IdrisDb in your tests.

IdrisDb NoSQL database will automatically download the correct binary for your platform. You can also pass a `libraries` map to adjust the download location for each platform.

Make sure to use `flutter test -j 1` to avoid tests running in parallel. This would break the automatic download.

## Contributors ✨

### IdrisDb Plus Contributors

Thanks to everyone contributing to IdrisDb Plus:

- [Ahmet Aydın](https://github.com/ahmtydn) - Project maintainer and lead developer


<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

For a complete list of original IdrisDb contributors, please visit the [original repository](https://github.com/IdrisDb/IdrisDb/graphs/contributors).
