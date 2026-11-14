# Motion design library

A personal index of 18 open-source animation tools for YouTube Shorts and explainer videos. Small projects are stored as snapshots of the upstream default branch (no git history). Large projects, and any project whose license does not allow a copy, are git submodules pinned to that same commit.

Snapshots keep the upstream license file as it shipped. Each snapshot folder has a `SOURCE.md` with the upstream URL, the commit that was copied, the date of the copy, and the license name.

## Catalog

| # | Name | Category | Upstream | License | Stored as | How this could help make Shorts or explainer videos |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Remotion skills | video-and-explainers | [remotion-dev/skills](https://github.com/remotion-dev/skills) | No license published | submodule | Agent instructions for building Remotion videos in React, including title cards, maps, and renders sized for Shorts. |
| 2 | Motion Canvas | video-and-explainers | [motion-canvas/motion-canvas](https://github.com/motion-canvas/motion-canvas) | MIT License | snapshot | Code-driven motion-graphics timeline for explanatory scenes that render out to video. |
| 3 | Anime.js | tweening-and-ui | [juliangarnier/anime](https://github.com/juliangarnier/anime) | MIT License | snapshot | Small JavaScript engine for SVG, text, and property tweens in web-rendered Shorts. |
| 4 | Manim | video-and-explainers | [3b1b/manim](https://github.com/3b1b/manim) | MIT License | snapshot | Grant Sanderson's engine for math and concept explainers that render straight to video. |
| 5 | Motion | tweening-and-ui | [motiondivision/motion](https://github.com/motiondivision/motion) | MIT License | submodule | React and JavaScript motion for UI, layout, and text in web-rendered explainers. |
| 6 | Ola | tweening-and-ui | [franciscop/ola](https://github.com/franciscop/ola) | MIT License | snapshot | Tiny number interpolator for counters, charts, and other smooth value motion. |
| 7 | TweenJS | tweening-and-ui | [CreateJS/TweenJS](https://github.com/CreateJS/TweenJS) | MIT License | snapshot | Canvas tweening for timeline-style web scenes and classic CreateJS animation. |
| 8 | Lottie Web | vector-and-2d | [airbnb/lottie-web](https://github.com/airbnb/lottie-web) | MIT License | submodule | Plays After Effects animations exported as JSON, for logo stings, icons, and lower thirds. |
| 9 | three.js | 3d | [mrdoob/three.js](https://github.com/mrdoob/three.js) | MIT License | submodule | WebGL and WebGPU scenes for product turns, abstract loops, and 3D title motion. |
| 10 | LUME | 3d | [lume/lume](https://github.com/lume/lume) | MIT License | submodule | HTML elements with 3D transforms, so DOM typography and WebGL can share one explainer. |
| 11 | Two.js | vector-and-2d | [jonobr1/two.js](https://github.com/jonobr1/two.js) | MIT License | snapshot | Renderer-agnostic 2D drawing for vector scenes on SVG, Canvas, or WebGL. |
| 12 | gltfjsx | 3d | [pmndrs/gltfjsx](https://github.com/pmndrs/gltfjsx) | MIT License | snapshot | Turns glTF models into JSX components for React and Remotion 3D shots. |
| 13 | Konva | vector-and-2d | [konvajs/konva](https://github.com/konvajs/konva) | MIT License | snapshot | Canvas scene graph with tweens for diagrams, callouts, and whiteboard explainers. |
| 14 | Godot | engines-and-apps | [godotengine/godot](https://github.com/godotengine/godot) | MIT License | submodule | 2D and 3D engine for animated scenes that can be captured or exported as video. |
| 15 | Blender | engines-and-apps | [blender/blender](https://github.com/blender/blender) | GPL-2.0-or-later | submodule | Modeling, motion graphics, and rendering for explainer shots and Shorts. |
| 16 | Babylon.js | 3d | [BabylonJS/Babylon.js](https://github.com/BabylonJS/Babylon.js) | Apache License 2.0 | submodule | Full web 3D engine for camera moves, product visuals, and interactive explainers. |
| 17 | Shifty | tweening-and-ui | [jeremyckahn/shifty](https://github.com/jeremyckahn/shifty) | MIT License | snapshot | Lightweight tween engine for precise numeric and CSS animation. |
| 18 | Proton | particles | [drawcall/Proton](https://github.com/drawcall/Proton) | MIT License | snapshot | Particle effects such as confetti, sparks, smoke, and magic trails over a Short. |

## Layout

```
agent-skills/             extra agent skill packs (none vendored yet)
video-and-explainers/     Remotion skills, Motion Canvas, Manim
tweening-and-ui/          Anime.js, Motion, Ola, TweenJS, Shifty
vector-and-2d/            Lottie Web, Two.js, Konva
3d/                       three.js, LUME, gltfjsx, Babylon.js
particles/                Proton
engines-and-apps/         Godot, Blender
scripts/update.sh         refresh snapshots and submodule pins
```

Remotion's repo is an agent-skills pack, and it is filed under `video-and-explainers/remotion-skills` with the other video tools. `agent-skills/` is the place for further skill packs.

## Checkout

Snapshots are already in the tree. Submodules are pins only, so a normal clone stays light. Fetch one when you need the code:

```bash
git submodule update --init --depth 1 3d/three.js
```

Omit `--depth 1` for full history. Blender's GitHub repo is a mirror and uses Git LFS. To fetch the source without LFS smudging, `GIT_LFS_SKIP_SMUDGE=1 git submodule update --init engines-and-apps/blender`.

`three.js` and `two.js` use `dev` as their default branch. Every pin tracks the upstream default branch.

## Update

`scripts/update.sh` replaces each snapshot with the latest default-branch tree and moves each submodule pin to that branch's current commit. It does not commit. It does not clone a submodule that is not already checked out. Pass `--snapshots` or `--submodules` to refresh only one side.

A snapshot update refuses to continue if a file is over 50 MiB, or if the upstream root no longer has a license file.

## Moved repositories

- `framer/motion` is now [motiondivision/motion](https://github.com/motiondivision/motion). Same repository, new owner. This library uses the new path.
- `a-jie/Proton` is now [drawcall/Proton](https://github.com/drawcall/Proton). Same repository, new owner. This library uses the new path.

Nothing from the original list was missing.

## License notes

Upstream license files are kept. Do not strip copyright or permission notices out of a snapshot.

- **Remotion skills** (`remotion-dev/skills`) publishes no license file, and `package.json` has no license field. A copy of those files is not granted, so this library does not vendor them. The folder is a submodule pin. Treat the upstream repo as all rights reserved unless Remotion adds a license.
- **Blender** is GPL-2.0-or-later. Redistribution is allowed under that license, including keeping this submodule link. Copyleft applies if you distribute Blender or a derivative. It is a submodule because the tree is large, not because the license forbids copying.
- **Konva** is MIT. GitHub's license detector reports it as "Other" because the copyright preamble names KineticJS and Konva; the permission text is the MIT license.
- Every other project here is MIT or Apache-2.0, which allows this kind of snapshot when the license file stays with the code.
