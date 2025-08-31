

## [0.6.4](https://github.com/HeoJeongBo/expo-live-activity/compare/v0.6.3...v0.6.4) (2025-08-31)

## [0.6.3](https://github.com/HeoJeongBo/expo-live-activity/compare/v0.6.2...v0.6.3) (2025-08-31)


### Features

* add automated release process enforcement ([e8acaaf](https://github.com/HeoJeongBo/expo-live-activity/commit/e8acaafd31b30f4da65a9661fe0e6409d28cf22e))

# [0.6.0](https://github.com/HeoJeongBo/expo-live-activity/compare/v0.5.2...v0.6.0) (2025-08-31)

### Features

* **Config Plugin**: Add comprehensive Expo Config Plugin for Live Activity setup ([a803aa6](https://github.com/HeoJeongBo/expo-live-activity/commit/a803aa6a5887b8f05a5a2bb05edc25030595f820))
  - Support for Apple Developer Team ID configuration
  - Custom Widget Bundle Identifier support
  - Environment variable integration for sensitive data
  - Automatic Widget Extension target creation
  - ActivityKit and WidgetKit framework integration

* **Development Environment**: Enhance development workflow ([a803aa6](https://github.com/HeoJeongBo/expo-live-activity/commit/a803aa6a5887b8f05a5a2bb05edc25030595f820))
  - Auto-fixing pre-commit hooks to prevent double commits
  - Environment variable template (.env.example)
  - Complete example project setup with plugin integration

* **Documentation**: Convert all documentation to English ([a803aa6](https://github.com/HeoJeongBo/expo-live-activity/commit/a803aa6a5887b8f05a5a2bb05edc25030595f820))
  - Comprehensive Plugin Usage Guide
  - Step-by-step configuration instructions
  - Troubleshooting guides

* **iOS Configuration**: Add iOS-specific Live Activity setup ([296eea9](https://github.com/HeoJeongBo/expo-live-activity/commit/296eea972d34e7931b7e47bf945f7db3ce035ede))

## [0.5.2](https://github.com/HeoJeongBo/expo-live-activity/compare/v0.5.0...v0.5.2) (2025-08-30)


### Bug Fixes

* andoird exec issue ([6484378](https://github.com/HeoJeongBo/expo-live-activity/commit/6484378e979047524f37d6161ba819f61a874fa7))
* android build issue ([0241e31](https://github.com/HeoJeongBo/expo-live-activity/commit/0241e31c86c5c5044d52ba863129ea69963d2013))
* improve type safety and fix TypeScript errors in ExpoLiveActivityModule ([b429661](https://github.com/HeoJeongBo/expo-live-activity/commit/b429661b1158f32216a533e701548cfbe0211774))

# [0.5.1](https://github.com/HeoJeongBo/expo-live-activity/compare/v0.5.0...v0.5.1) (2025-01-27)

### Bug Fixes

* fix TypeScript type errors in ExpoLiveActivityModule ([commit](https://github.com/HeoJeongBo/expo-live-activity/commit/))
* replace all `any` types with proper types in Android interface ([commit](https://github.com/HeoJeongBo/expo-live-activity/commit/))
* improve type safety and code consistency

# [0.5.0](https://github.com/HeoJeongBo/expo-live-activity/compare/v0.2.0...v0.5.0) (2025-08-30)


### Bug Fixes

* husky prefix script ([4bd1978](https://github.com/HeoJeongBo/expo-live-activity/commit/4bd197875ddd5a2ba5134fdaeaa0a8fe6c15608d))
* husky script ([35f592e](https://github.com/HeoJeongBo/expo-live-activity/commit/35f592e7c8c4fe899d79e8c553b7d3a73090e577))
* resolve formatting issues and update Claude settings ([8d9839b](https://github.com/HeoJeongBo/expo-live-activity/commit/8d9839be72466e437a56e2d392376a8669106993))


### Features

* add android live activity ([2bec1cb](https://github.com/HeoJeongBo/expo-live-activity/commit/2bec1cb92488a250894b67c1c7366ec4f3d2593b))
* add audio recording ([22aa955](https://github.com/HeoJeongBo/expo-live-activity/commit/22aa955807fbbcc79e35ceb1660c69503127d180))
* add expo-audio integration with Live Activity ([c1ac236](https://github.com/HeoJeongBo/expo-live-activity/commit/c1ac236e73fba436df8f16f442ba5484d8718edc))
* add ios live activity ([538c6db](https://github.com/HeoJeongBo/expo-live-activity/commit/538c6db5d205f0d01267ed3cdcf5430d5f113cd5))
* add Live Activity widget support with @bacons/apple-targets ([4c535af](https://github.com/HeoJeongBo/expo-live-activity/commit/4c535afb116fc772f498a95b4dab31e315527cf8))
* enhance pre-commit workflow with automatic linting ([ca502c8](https://github.com/HeoJeongBo/expo-live-activity/commit/ca502c894bb381a2a14d76a31c38bf99609cb43d))
* eslint disable ([c183539](https://github.com/HeoJeongBo/expo-live-activity/commit/c18353986759666c08f2e081203fbf95ea2c619c))
* setup Husky pre-commit hooks with TypeScript type checking ([c2ae4db](https://github.com/HeoJeongBo/expo-live-activity/commit/c2ae4dbf555cc9522dda07dd9789146cc3aab90c))
* update md file ([2a1d8d4](https://github.com/HeoJeongBo/expo-live-activity/commit/2a1d8d4bff81bb6d5acae0c54a3cc5477217ba14))

# 0.2.0 (2025-07-26)


### Bug Fixes

* add public access for scoped npm package ([02c66d3](https://github.com/HeoJeongBo/expo-live-activity/commit/02c66d37f02f14fbd4efc96f05603e4ae4455d65))
* disable test requirement in release process ([ce6d50f](https://github.com/HeoJeongBo/expo-live-activity/commit/ce6d50ff5fc8d0165025900b18769f98a5457be2))


### Features

* add release-it ([26a552e](https://github.com/HeoJeongBo/expo-live-activity/commit/26a552e941ce78340feae37a7f315d10ee55f782))
* change package name to scoped package ([ec30437](https://github.com/HeoJeongBo/expo-live-activity/commit/ec30437cd5dae704415928df5325c26081e4cb0d))
* change to bun & biome ([7cd3588](https://github.com/HeoJeongBo/expo-live-activity/commit/7cd35887a3f2db70781a850717ea13520f8c0675))
* remove eslint completely, use biome only ([17dd0d1](https://github.com/HeoJeongBo/expo-live-activity/commit/17dd0d17783d9c8f0525f6af39b4776428170ec7))
* setup bun, biome, and release-it for automated deployment ([ecea1ca](https://github.com/HeoJeongBo/expo-live-activity/commit/ecea1ca0e787e233c0b45024d2c32c96afe8bdf2))
* update readme by claude ([4af594b](https://github.com/HeoJeongBo/expo-live-activity/commit/4af594bbe586fd7d36ed512f618255df827f2e94))
