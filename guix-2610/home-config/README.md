# My Home configuration

Used guide from: https://guix.gnu.org/blog/2022/keeping-ones-home-tidy/

It was created with: `guix home import ~/projects/guix-systems/guix-2610/home-config`

WARNING! Before activation you have to checkout:
```shell
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/hpaluch/guix-packages.git
```
And follow its README to add my favorite packages (`pil-git-scripts` and `procps-top-normal`)

Testing (from guide): `guix home container ~/projects/guix-systems/guix-2610/home-config/home-configuration.scm`

Applying (from guide - not yet tested: `guix home reconfigure ~/projects/guix-systems/guix-2610/home-config/home-configuration.scm``
