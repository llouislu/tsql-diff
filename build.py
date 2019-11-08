#!/usr/bin/env python3

from datetime import datetime
from pathlib import Path


build_target_folder = 'build'

build_tasks = ['install', 'uninstall']

build_lists = {
    'install': [
        '_install', '_fetchresultmeta', 'loadsqlfile', 'validatesql', 'checkstringpair', 'checkpair', 'checkfolder'
    ],
    'uninstall': ['_uninstall']
}

def add_comment(fo, comment='\n'):
    fo.write(comment)


def add_author_disclaimer(fo):
    license_disclaimer = '''
/*
Copyright {year} Louis Lu

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
    '''.format(year=datetime.now().year)
    add_comment(fo, license_disclaimer.strip())

def add_filename(fo, filename, mark='start'):
    lines = ['\n', '/*', '{} {}'.format(mark, filename), '*/', '\n']
    fo.write('\n'.join(lines))

def build_files(output_file, source_files):
    Path(build_target_folder).mkdir(exist_ok=True)
    output_path = Path(build_target_folder) / Path(output_file)
    with open(output_path, 'w') as fo:
        add_author_disclaimer(fo)
        for source_file in source_files:
            add_filename(fo, str(source_file), mark='start')
            with open(source_file) as source:
                fo.write(source.read())
            add_filename(fo, str(source_file), mark='end')

def generate_build_paths(build_file_list):
    for file in build_file_list:
        yield Path('./src/') / Path('checker.{}.sql'.format(file))

if __name__ == '__main__':
    for task in build_tasks:
        source_files = generate_build_paths(build_lists[task])
        output_file = '{}.sql'.format(task)
        build_files(output_file, source_files)
