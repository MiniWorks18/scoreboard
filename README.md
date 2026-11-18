# scoreboard

A scoring app for multiple teams/players.

Designed to run on ios/android/web. 

## Demo

Scoreboard: https://miniworks18.github.io/scoreboard/

## Getting Started

Install Flutter 3.50 or newer and Google Chrome, then run from the repository directory:

```sh
flutter pub get
flutter run -d chrome
```

While the app is running, press `r` in the terminal to reload changes or `R` for a full restart. After adding dependencies, stop the app, run `flutter pub get`, and start it again.

## Publishing to GitHub Pages

Keep the Flutter source on `main`. The `gh-pages` branch holds the built website. Updating `main` does not automatically publish the app.

### One-time setup

From the repository directory, create a separate checkout for the deployment branch:

```sh
git fetch origin
git worktree add -b gh-pages ../scoreboard-pages origin/gh-pages
```

If a local `gh-pages` branch already exists, use `git worktree add ../scoreboard-pages gh-pages` instead. Skip this step if the checkout already exists.

On GitHub, open **Settings → Pages** and choose:

- **Source:** Deploy from a branch
- **Branch:** `gh-pages`
- **Folder:** `/ (root)`

### Publish an update

After testing and committing your source changes on `main`, run these commands from the repository directory:

```sh
flutter pub get
flutter build web --base-href "/scoreboard/"
```

The build goes into `build/web`. The base path matches the site's GitHub Pages address.

Copy the build into the deployment checkout. This replaces its previous website files, so keep that checkout dedicated to deployment:

```sh
rsync -av --delete --exclude='.git' build/web/ ../scoreboard-pages/
touch ../scoreboard-pages/.nojekyll
```

Commit and push the published files:

```sh
git -C ../scoreboard-pages add -A
git -C ../scoreboard-pages commit -m "Deploy updated scoreboard"
git -C ../scoreboard-pages push origin gh-pages
```

GitHub then publishes the update at https://miniworks18.github.io/scoreboard/. Check the repository's **Actions** tab for deployment progress, then refresh or fully reopen the app on your phone.
