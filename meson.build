# project name and programming language
project('io.github.leolost2605.gradebook', 'vala', 'c')

i18n = import('i18n')

subdir ('po')

conf = configuration_data()
# Get the package data directory under Meson
pkgdatadir = join_paths([ get_option('prefix'),
                          get_option('datadir'),
                          meson.project_name() ])
conf.set_quoted('APP_ID', meson.project_name())
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('PKGDATADIR', pkgdatadir)
conf.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))

# Other configs
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
add_global_arguments('-DDATADIR="' + get_option('datadir') + '"', language: 'c')
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

# Arguments for C
c_args = [
  '-include', 'config.h',
  '-w'
]

# Arguments for Vala
vala_args = ['--target-glib=2.50', meson.source_root() + '/src/config.vapi']

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    'src' / 'application.vala',
    'src' / 'grade.vala',
    'src' / 'subject.vala',
    'src' / 'new-grade-dialog.vala',
    'src' / 'category.vala',
    'src' / 'edit-subject-dialog.vala',
    'src' / 'add-category-dialog.vala',
    'src' / 'subject-manager.vala',
    'src' / 'subject-page.vala',
    'src' / 'subject-parser.vala',
    'src' / 'window.vala',
    dependencies: [
        dependency('gtk4'),
        dependency('libadwaita-1'),
        dependency('json-glib-1.0')
    ],
    c_args: c_args, vala_args: vala_args,
    install: true
)

# Create desktop file
desktop_file = i18n.merge_file(
  input: 'data/io.github.leolost2605.gradebook.desktop.in',
  output: 'io.github.leolost2605.gradebook.desktop',
  type: 'desktop',
  po_dir: './po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

# Validate desktop file
desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils,
    args: [desktop_file]
  )
endif

# Create appdata file
appdata_file = i18n.merge_file(
  input: 'data/io.github.leolost2605.gradebook.metainfo.xml.in',
  output: 'io.github.leolost2605.gradebook.metainfo.xml',
  po_dir: './po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)

# Validate appdata file
appstreamcli = find_program('appstreamcli', required: false)
if appstreamcli.found()
  test('Validate appdata file', appstreamcli,
    args: ['validate', '--no-net', '--explain', appdata_file.full_path()],
    workdir: meson.current_build_dir()
  )
endif

# Install our icons in all the required sizes
icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        'data' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
        rename: meson.project_name() + '.svg'
    )
    install_data(
        'data' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i + '@2' / 'apps',
        rename: meson.project_name() + '.svg'
    )
endforeach

install_data(
        'data' / 'dock-left-symbolic.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'symbolic' / 'apps',
        rename: 'dock-left-symbolic.svg'
    )
install_data(
        'data' / 'user-trash-symbolic.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'symbolic' / 'apps',
        rename: 'user-trash-symbolic.svg'
    )
