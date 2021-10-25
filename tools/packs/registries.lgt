%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  This file is part of Logtalk <https://logtalk.org/>
%  Copyright 1998-2021 Paulo Moura <pmoura@logtalk.org>
%  SPDX-License-Identifier: Apache-2.0
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


:- object(registries,
	imports((packs_common, options))).

	:- info([
		version is 0:25:0,
		author is 'Paulo Moura',
		date is 2021-10-25,
		comment is 'Registry handling predicates.'
	]).

	:- public(list/0).
	:- mode(list, one).
	:- info(list/0, [
		comment is 'Prints a list of all defined registries, including how defined (``git``, ``archive``, or ``directory``) and  if they are pinned.'
	]).

	:- public(describe/1).
	:- mode(describe(+atom), one).
	:- info(describe/1, [
		comment is 'Prints all registry entries.',
		argnames is ['Registry']
	]).

	:- public(defined/3).
	:- mode(defined(?atom, ?atom, ?boolean), zero_or_more).
	:- info(defined/3, [
		comment is 'Enumerates by backtracking all defined registries and how they are defined (``git``, ``archive``, or ``directory``) plus if they are pinned.',
		argnames is ['Registry', 'HowDefined', 'Pinned']
	]).

	:- public(add/3).
	:- mode(add(+atom, +atom, ++list(compound)), zero_or_one).
	:- info(add/3, [
		comment is 'Adds a new registry using the given options. Fails if the registry cannot be added or if it is already defined. HTTPS URLs must end with either a ``.git`` extension or a an archive extension. A ``file://`` URL can be used for a local directory.',
		argnames is ['Registry', 'URL', 'Options'],
		remarks is [
			'Registry name' - 'Must be the URL basename when using a git URL or a local directory URL. Must also be the declared registry name in the registry specification object.',
			'``force(Boolean)`` option' - 'Force re-installation if the registry is already defined. Default is ``false``.',
			'``clean(Boolean)`` option' - 'Clean registry archive after updating. Default is ``false``.',
			'``verbose(Boolean)`` option' - 'Verbose adding steps. Default is ``false``.'
		]
	]).

	:- public(add/2).
	:- mode(add(+atom, +atom), zero_or_one).
	:- info(add/2, [
		comment is 'Adds a new registry using default options. Fails if the registry cannot be added or if it is already defined. HTTPS URLs must end with either a ``.git`` extension or a an archive extension. A ``file://`` URL can be used for a local directory.',
		argnames is ['Registry', 'URL'],
		remarks is [
			'Registry name' - 'Must be the URL basename when using a git URL or a local directory URL. Must also be the declared registry name in the registry specification object.'
		]
	]).

	:- public(add/1).
	:- mode(add(+atom), zero_or_one).
	:- info(add/1, [
		comment is 'Adds a new registry from a git cloning URL or a local directory URL using default options. Fails if the registry cannot be added or if it is already defined. HTTPS URLs must end with a ``.git`` extension. A ``file://`` URL can be used for a local directory.',
		argnames is ['URL'],
		remarks is [
			'Limitations' - 'Cannot be used for archive download URLs.',
			'Registry name' - 'Taken from the URL basename.'
		]
	]).

	:- public(update/2).
	:- mode(update(+atom, ++list(compound)), zero_or_one).
	:- info(update/2, [
		comment is 'Updates a defined registry using the specified options. Fails if the registry is not defined.',
		argnames is ['Registry', 'Options'],
		remarks is [
			'``force(Boolean)`` option' - 'Force update if the registry is pinned. Default is ``false``.',
			'``clean(Boolean)`` option' - 'Clean registry archive after updating. Default is ``false``.',
			'``verbose(Boolean)`` option' - 'Verbose updating steps. Default is ``false``.'
		]
	]).

	:- public(update/1).
	:- mode(update(+atom), zero_or_one).
	:- info(update/1, [
		comment is 'Updates a defined registry using default options. Fails if the registry is not defined.',
		argnames is ['Registry']
	]).

	:- public(update/0).
	:- mode(update, zero_or_one).
	:- info(update/0, [
		comment is 'Updates all defined registries using default options.'
	]).

	:- public(delete/2).
	:- mode(delete(+atom, ++list(compound)), zero_or_one).
	:- info(delete/2, [
		comment is 'Deletes a registry using the specified options (if not pinned).',
		argnames is ['Registry', 'Options'],
		remarks is [
			'``force(Boolean)`` option' - 'Force deletion if the registry is pinned or there are installed registry packs. Default is ``false``.',
			'``clean(Boolean)`` option' - 'Clean registry archive after deleting. Default is ``false``.',
			'``verbose(Boolean)`` option' - 'Verbose deleting steps. Default is ``false``.'
		]
	]).

	:- public(delete/1).
	:- mode(delete(+atom), zero_or_one).
	:- info(delete/1, [
		comment is 'Deletes a registry using default options.',
		argnames is ['Registry']
	]).

	:- public(clean/1).
	:- mode(clean(+atom), zero_or_one).
	:- info(clean/1, [
		comment is 'Cleans all registry archives. Fails if the registry is not defined.',
		argnames is ['Registry']
	]).

	:- public(clean/0).
	:- mode(clean, one).
	:- info(clean/0, [
		comment is 'Cleans all archives for all registries.'
	]).

	:- public(provides/2).
	:- mode(provides(?atom, ?atom), zero_or_more).
	:- info(provides/2, [
		comment is 'Enumerates by backtracking all packs provided by a registry.',
		argnames is ['Registry', 'Pack']
	]).

	:- public(lint/1).
	:- mode(lint(+atom), zero_or_one).
	:- info(lint/1, [
		comment is 'Checks the registry specification. Fails if the registry is not defined.',
		argnames is ['Registry']
	]).

	:- public(lint/0).
	:- mode(lint, one).
	:- info(lint/0, [
		comment is 'Checks all registry specifications.'
	]).

	:- private(deleted_registry_/1).
	:- dynamic(deleted_registry_/1).
	:- mode(deleted_registry_(?atom), zero_or_one).
	:- info(deleted_registry_/1, [
		comment is 'Table of deleted registries.',
		argnames is ['Registry']
	]).
	:- uses(list, [
		member/2
	]).

	:- uses(logtalk, [
		expand_library_path/2, loaded_file_property/2, print_message/3
	]).

	:- uses(os, [
		decompose_file_name/3, decompose_file_name/4, delete_file/1,
		directory_exists/1, directory_files/3, ensure_file/1, file_exists/1,
		internal_os_path/2, make_directory_path/1, operating_system_type/1,
		path_concat/3, shell/1
	]).

	:- uses(type, [
		check/2, valid/2
	]).

	% registry info predicates

	list :-
		print_message(information, packs, @'Defined registries:'),
		findall(
			defined(Registry, HowDefined, Pinned),
			defined(Registry, HowDefined, Pinned),
			DefinedRegistries
		),
		(	DefinedRegistries == [] ->
			print_message(information, packs, @'  (none)')
		;	print_message(information, packs, defined_registries(DefinedRegistries))
		).

	describe(Registry) :-
		check(atom, Registry),
		(	registry_object(Registry, RegistryObject) ->
			RegistryObject::description(Description),
			RegistryObject::home(Home),
			RegistryObject::clone(Clone),
			RegistryObject::archive(Archive),
			(	pinned(Registry) ->
				Pinned = true
			;	Pinned = false
			),
			print_message(information, packs, registry_info(Registry,Description,Home,Clone,Archive,Pinned))
		;	print_message(error, packs, unknown_registry(Registry)),
			fail
		).

	defined(Registry, HowDefined, Pinned) :-
		check(var_or(atom), Registry),
		check(var_or(atom), HowDefined),
		check(var_or(boolean), Pinned),
		expand_library_path(logtalk_packs(registries), Directory),
		directory_files(Directory, Registries, [type(directory), dot_files(false), paths(relative)]),
		member(Registry, Registries),
		path_concat(Directory, Registry, Path),
		read_url(Path, URL),
		decompose_file_name(URL, _, Name, Extension),
		(	Extension == '.git' ->
			HowDefined = git
		;	Name == Registry ->
			HowDefined = directory
		;	Name == Extension, Extension == '' ->
			% URL ends with a /
			HowDefined = directory
		;	HowDefined = archive
		),
		(	pinned(Registry) ->
			Pinned = true
		;	Pinned = false
		).

	% registry directory predicates

	directory(Registry, Directory) :-
		(	var(Registry) ->
			implements_protocol(RegistryObject, registry_protocol),
			RegistryObject::name(Registry)
		;	check(atom, Registry),
			implements_protocol(RegistryObject, registry_protocol),
			RegistryObject::name(Registry),
			!
		),
		\+ deleted_registry_(Registry),
		expand_library_path(logtalk_packs(registries), Registries),
		path_concat(Registries, Registry, Directory),
		directory_exists(Directory).

	directory(Directory) :-
		expand_library_path(logtalk_packs(registries), Directory).

	% add registry predicates

	add(Registry, URL, UserOptions) :-
		check(atom, Registry),
		check(atom, URL),
		fix_url(URL, URLFixed),
		^^check_options(UserOptions),
		^^merge_options(UserOptions, Options),
		add_registry(Registry, URLFixed, Options).

	add(Registry, URL) :-
		check(atom, Registry),
		check(atom, URL),
		fix_url(URL, URLFixed),
		^^default_options(Options),
		add_registry(Registry, URLFixed, Options).

	add(URL) :-
		check(atom, URL),
		fix_url(URL, URLFixed),
		decompose_file_name(URLFixed, _, Registry, _),
		^^default_options(Options),
		add_registry(Registry, URLFixed, Options).

	fix_url(URL, URLFixed) :-
		(	sub_atom(URL, _, _, 0, '/') ->
			sub_atom(URL, 0, _, 1, URLFixed)
		;	URLFixed = URL
		).

	add_registry(Registry, URL, Options) :-
		print_message(comment, packs, adding_registry(Registry)),
		(	registry_object(Registry, _),
			member(force(false), Options) ->
			print_message(error, packs, registry_already_defined(Registry)),
			fail
		;	true
		),
		decompose_file_name(URL, _, Name, Extension),
		(	Extension = '',
			sub_atom(URL, 0, _, _, 'file://') ->
			(	Name \== Registry ->
				print_message(error, packs, registry_name_must_be(Name)),
				fail
			;	add_directory(Registry, URL, Path, Options)
			)
		;	Extension == '.git' ->
			(	Name \== Registry ->
				print_message(error, packs, registry_name_must_be(Name)),
				fail
			;	clone(Registry, URL, Path, Options)
			)
		;	^^supported_archive(Extension) ->
			download(Registry, URL, Archive, Options),
			uncompress(Registry, Archive, Path, Options)
		;	atom_concat(Name, Extension, Archive),
			print_message(error, packs, unsupported_archive_format(Archive)),
			fail
		),
		save_url(Path, URL),
		^^load_registry(Path),
		retractall(deleted_registry_(Registry)),
		(	member(clean(true), Options) ->
			delete_archives(Registry)
		;	true
		),
		^^print_readme_file_path(Path),
		print_message(comment, packs, registry_added(Registry)).

	add_directory(Registry, URL, Path, Options) :-
		atom_concat('file://', Directory0, URL),
		(	sub_atom(Directory0, _, _, 0, '/') ->
			sub_atom(Directory0, _, _, 1, Directory)
		;	Directory = Directory0
		),
		make_registry_installation_directory(Registry, Path, OSPath),
		path_concat(Directory, '.git', Git),
		(	directory_exists(Git) ->
			(	member(verbose(true), Options) ->
				atom_concat('git clone -v ', URL, Command0)
			;	atom_concat('git clone -q ', URL, Command0)
			),
			atom_concat(Command0, ' "', Command1),
			atom_concat(Command1, OSPath, Command2),
			atom_concat(Command2, '"', Command),
			^^command(Command, registry_cloning_failed(Registry, URL))
		;	operating_system_type(windows) ->
			internal_os_path(Directory, OSDirectory),
			atom_concat('xcopy /E /I "', OSDirectory, Command0),
			atom_concat(Command0, '" "', Command1),
			atom_concat(Command1, OSPath, Command2),
			atom_concat(Command2, '"', Command),
			^^command(Command, registry_directory_copy_failed(Registry, URL))
		;	internal_os_path(Directory, OSDirectory),
			atom_concat('cp -R "', OSDirectory, Command0),
			atom_concat(Command0, '/." "', Command1),
			atom_concat(Command1, OSPath, Command2),
			atom_concat(Command2, '"', Command),
			^^command(Command, registry_directory_copy_failed(Registry, URL))
		).

	% delete registry predicates

	delete(Registry, UserOptions) :-
		check(atom, Registry),
		^^check_options(UserOptions),
		^^merge_options(UserOptions, Options),
		print_message(comment, packs, deleting_registry(Registry)),
		(	directory(Registry, Directory0) ->
			(	pinned(Registry),
				member(force(false), Options) ->
				print_message(error, packs, cannot_delete_pinned_registry(Registry)),
				fail
			;	true
			),
			(	installed_registry_packs(Registry),
				member(force(false), Options) ->
				print_message(error, packs, cannot_delete_registry_with_installed_packs(Registry)),
				fail
			;	true
			),
			internal_os_path(Directory0, Directory),
			(	operating_system_type(windows) ->
				(	member(verbose(true), Options) ->
					atom_concat('del /s /q "', Directory, Command0),
					atom_concat(Command0, '" && rmdir /s /q "', Command1),
					atom_concat(Command1, Directory, Command2),
					atom_concat(Command2, '"', Command)
				;	atom_concat('del /s /q "', Directory, Command0),
					atom_concat(Command0, '" > nul 2>&1 && rmdir /s /q "', Command1),
					atom_concat(Command1, Directory, Command2),
					atom_concat(Command2, '" > nul 2>&1', Command)
				)
			;	% assume unix
				(	member(verbose(true), Options) ->
					atom_concat('rm -rvf "', Directory, Command0)
				;	atom_concat('rm -rf "', Directory, Command0)
				),
				atom_concat(Command0, '"', Command)
			),
			^^command(Command, registry_deletion_failed(Registry, Directory)),
			assertz(deleted_registry_(Registry)),
			(	member(clean(true), Options) ->
				delete_archives(Registry)
			;	true
			),
			print_message(comment, packs, registry_deleted(Registry))
		;	print_message(error, packs, unknown_registry(Registry)),
			fail
		).

	delete(Registry) :-
		delete(Registry, []).

	% update registry predicates

	update(Registry, UserOptions) :-
		check(atom, Registry),
		^^check_options(UserOptions),
		^^merge_options(UserOptions, Options),
		(	deleted_registry_(Registry) ->
			print_message(error, packs, unknown_registry(Registry)),
			fail
		;	registry_object(Registry, RegistryObject) ->
			(	pinned(Registry),
				member(force(false), Options) ->
				print_message(error, packs, cannot_update_pinned_registry(Registry)),
				fail
			;	true
			),
			expand_library_path(logtalk_packs(registries), Registries),
			path_concat(Registries, Registry, Path),
			path_concat(Path, '.git', Git),
			(	directory_exists(Git) ->
				RegistryObject::clone(URL),
				update_clone(Registry, URL, Path, Updated, Options)
			;	RegistryObject::archive(URL),
				update_archive(Registry, URL, Updated, Options)
			),
			(	Updated == false ->
				print_message(comment, packs, up_to_date_registry(Registry, URL))
			;	object_property(RegistryObject, file(File)),
				loaded_file_property(File, parent(Loader)),
				logtalk_load(Loader, [reload(always), source_data(on), hook(registry_loader_hook)]),
				(	member(clean(true), Options) ->
					delete_archives(Registry)
				;	true
				),
				print_message(comment, packs, registry_updated(Registry, URL))
			)
		;	print_message(error, packs, unknown_registry(Registry)),
			fail
		).

	update(Registry) :-
		update(Registry, []).

	% use a failure-driven loop so that we don't stop updating
	% the defined registries if the update for one of them fails
	update :-
		print_message(comment, packs, @'Updating defined registries:'),
		defined(Registry, HowDefined, Pinned),
		(	Pinned == true ->
			registry_object(Registry, RegistryObject),
			(	HowDefined == git ->
				RegistryObject::clone(URL)
			;	RegistryObject::archive(URL)
			),
			print_message(comment, packs, pinned_registry(Registry, URL))
		;	update(Registry, [])
		),
		fail.
	update :-
		print_message(comment, packs, @'Registries updating completed').

	update_clone(_, _, Path, false, _) :-
		internal_os_path(Path, OSPath),
		atom_concat('git -C "', OSPath, Command0),
		(	operating_system_type(windows) ->
			atom_concat(Command0, '" remote update > nul 2>&1 && git -C "', Command1),
			atom_concat(Command1, OSPath, Command2),
			atom_concat(Command2, '" status -uno | find "up to date" > nul', Command)
		;	atom_concat(Command0, '" remote update > /dev/null 2>&1 && git -C "', Command1),
			atom_concat(Command1, OSPath, Command2),
			atom_concat(Command2, '" status -uno | grep -q "up to date"', Command)
		),
		shell(Command),
		!.
	update_clone(Registry, URL, Path, true, Options) :-
		print_message(comment, packs, updating_registry(Registry, URL)),
		internal_os_path(Path, OSPath),
		atom_concat('git -C "', OSPath, Command0),
		atom_concat(Command0, '" pull ', Command1),
		(	member(verbose(true), Options) ->
			atom_concat(Command1, '-v',  Command)
		;	atom_concat(Command1, '-q',  Command)
		),
		^^command(Command, registry_clone_pull_failed(Registry, OSPath)).

	update_archive(Registry, URL, true, Options) :-
		print_message(comment, packs, updating_registry(Registry, URL)),
		download(Registry, URL, Archive, Options),
		uncompress(Registry, Archive, _, Options).

	% clean predicates

	clean(Registry) :-
		check(atom, Registry),
		(	registry_object(Registry, _) ->
			delete_archives(Registry)
		;	print_message(error, packs, unknown_registry(Registry)),
			fail
		).

	clean :-
		expand_library_path(logtalk_packs(registries), Directory),
		directory_files(Directory, Registries, [type(directory), dot_files(false)]),
		member(Registry, Registries),
		delete_archives(Registry),
		fail.
	clean.

	delete_archives(Registry) :-
		expand_library_path(logtalk_packs(archives), Archives),
		path_concat(Archives, registries, ArchivesRegistries),
		path_concat(ArchivesRegistries, Registry, ArchivesRegistriesRegistry),
		(	directory_exists(ArchivesRegistriesRegistry) ->
			directory_files(ArchivesRegistriesRegistry, Files, [type(regular), dot_files(false), paths(absolute)]),
			forall(member(File, Files), delete_file(File))
		;	true
		).

	% provides predicates

	provides(Registry, Pack) :-
		check(var_or(atom), Registry),
		check(var_or(atom), Pack),
		registry_object(Registry, RegistryObject),
		object_property(RegistryObject, file(RegistryFile)),
		loaded_file_property(RegistryFile, parent(Loader)),
		loaded_file_property(PackFile, parent(Loader)),
		loaded_file_property(PackFile, object(PackObject)),
		implements_protocol(PackObject, pack_protocol),
		PackObject::name(Pack).

	% options handling

	default_option(verbose(false)).
	default_option(clean(false)).
	default_option(force(false)).

	valid_option(verbose(Boolean)) :-
		valid(boolean, Boolean).
	valid_option(clean(Boolean)) :-
		valid(boolean, Boolean).
	valid_option(force(Boolean)) :-
		valid(boolean, Boolean).

	% pinned registry handling

	pin(Registry) :-
		(	pin_file(Registry, File) ->
			ensure_file(File)
		;	print_message(error, packs, unknown_registry(Registry)),
			fail
		).

	unpin(Registry) :-
		(	pin_file(Registry, File) ->
			(	file_exists(File) ->
				delete_file(File)
			;	true
			)
		;	print_message(error, packs, unknown_registry(Registry)),
			fail
		).

	pinned(Registry) :-
		(	pin_file(Registry, File) ->
			file_exists(File)
		;	print_message(error, packs, unknown_registry(Registry)),
			fail
		).

	pin_file(Registry, File) :-
		check(atom, Registry),
		directory(Registry, Directory),
		path_concat(Directory, 'PINNED.packs', File).

	% registry URL definition predicates

	save_url(Path, URL) :-
		path_concat(Path, 'URL.packs', File),
		open(File, write, Stream),
		writeq(Stream, URL), write(Stream, '.\n'),
		close(Stream).

	read_url(Path, URL) :-
		path_concat(Path, 'URL.packs', File),
		open(File, read, Stream),
		read(Stream, URL),
		close(Stream).

	url_file(Registry, File) :-
		check(atom, Registry),
		directory(Registry, Directory),
		path_concat(Directory, 'URL.packs', File).

	% registry readme predicates

	readme(Registry, ReadMeFile) :-
		directory(Registry, Directory),
		^^readme_file_path(Directory, ReadMeFile).

	% lint predicates

	lint(Registry) :-
		check(atom, Registry),
		(	registry_object(Registry, RegistryObject) ->
			lint_registry(Registry, RegistryObject)
		;	print_message(error, packs, unknown_registry(Registry)),
			fail
		).

	lint :-
		print_message(comment, packs, @'Lint checking all registries'),
		registry_object(Registry, RegistryObject),
		lint_registry(Registry, RegistryObject),
		fail.
	lint :-
		print_message(comment, packs, @'Lint checked all registries').

	lint_registry(Registry, RegistryObject) :-
		print_message(comment, packs, linting_registry(Registry)),
		lint_check(name, Registry, RegistryObject),
		lint_check(description, Registry, RegistryObject),
		lint_check(home, Registry, RegistryObject),
		lint_check(clone, Registry, RegistryObject),
		lint_check(archive, Registry, RegistryObject),
		print_message(comment, packs, linted_registry(Registry)).

	lint_check(name, Registry, RegistryObject) :-
		atom_concat(Registry, '_registry', ExpectedRegistryObject),
		(	RegistryObject == ExpectedRegistryObject ->
			true
		;	print_message(warning, packs, 'Registry object expected name is ~q but ~q is used!'+[ExpectedRegistryObject, RegistryObject])
		).
	lint_check(description, _Registry, RegistryObject) :-
		(	RegistryObject::description(_) ->
			true
		;	print_message(warning, packs, @'The description/1 predicate is missing or failed safety check!')
		).
	lint_check(home, _Registry, RegistryObject) :-
		(	RegistryObject::home(_) ->
			true
		;	print_message(warning, packs, @'The home/1 predicate is missing or failed safety check!')
		).
	lint_check(clone, Registry, RegistryObject) :-
		(	RegistryObject::clone(URL) ->
			lint_check_clone_url(Registry, URL)
		;	print_message(warning, packs, @'The clone/1 predicate is missing or failed safety check!')
		).
	lint_check(archive, _Registry, RegistryObject) :-
		(	RegistryObject::archive(URL) ->
			lint_check_archive_url(URL)
		;	print_message(warning, packs, @'The archive/1 predicate is missing or failed safety check!')
		).

	lint_check_clone_url(Registry, URL):-
		decompose_file_name(URL, _, Name, Extension),
		(	Extension \== '.git' ->
			print_message(warning, packs, 'Git cloning URL should end with ".git"!')
		;	Name == Registry ->
			true
		;	print_message(warning, packs, 'Git repos should have the same name as the registry!')
		).
	lint_check_archive_url(URL) :-
		decompose_file_name(URL, _, _, Extension),
		(	^^supported_archive(Extension) ->
			true
		;	Extension == '' ->
			print_message(warning, packs, 'Archive extension missing!')
		;	print_message(warning, packs, 'Archive extension not supported!')
		).

	% auxiliary predicates

	registry_directory(Registry, Directory) :-
		registry_object(Registry, _),
		expand_library_path(logtalk_packs(registries), RegistriesDirectory),
		directory_files(RegistriesDirectory, Registries, [type(directory), dot_files(false), paths(relative)]),
		member(Registry, Registries),
		path_concat(RegistriesDirectory, Registry, Directory).

	registry_object(Registry, RegistryObject) :-
		(	var(Registry) ->
			implements_protocol(RegistryObject, registry_protocol),
			RegistryObject::name(Registry)
		;	implements_protocol(RegistryObject, registry_protocol),
			RegistryObject::name(Registry),
			!
		),
		\+ deleted_registry_(Registry).

	clone(Registry, URL, Path, Options) :-
		expand_library_path(logtalk_packs(registries), Registries),
		path_concat(Registries, Registry, Path),
		internal_os_path(Path, OSPath),
		(	member(verbose(true), Options) ->
			atom_concat('git clone -v ', URL, Command0)
		;	atom_concat('git clone -q ', URL, Command0)
		),
		atom_concat(Command0, ' "', Command1),
		atom_concat(Command1, OSPath, Command2),
		atom_concat(Command2, '"', Command),
		^^command(Command, registry_cloning_failed(Registry, URL)).

	download(Registry, URL, Archive, Options) :-
		expand_library_path(logtalk_packs(archives), Archives),
		path_concat(Archives, registries, ArchivesRegistries),
		path_concat(ArchivesRegistries, Registry, ArchivesRegistriesRegistry),
		decompose_file_name(URL, _, Basename),
		path_concat(ArchivesRegistriesRegistry, Basename, Archive0),
		internal_os_path(Archive0, Archive),
		make_directory_path(ArchivesRegistriesRegistry),
		(	member(verbose(true), Options) ->
			atom_concat('curl -v -L -o "', Archive, Command0)
		;	atom_concat('curl -s -S -L -o "', Archive, Command0)
		),
		atom_concat(Command0, '" ', Command1),
		atom_concat(Command1, URL, Command),
		^^command(Command, registry_download_failed(Registry, URL)).

	uncompress(Registry, Archive, Path, Options) :-
		make_registry_installation_directory(Registry, Path, OSPath),
		^^tar_command(Tar),
		(	member(verbose(true), Options) ->
			atom_concat(Tar, ' -xvf "', Command0)
		;	atom_concat(Tar, ' -xf "', Command0)
		),
		atom_concat(Command0, Archive, Command1),
		atom_concat(Command1, '" --strip 1 --directory "', Command2),
		atom_concat(Command2, OSPath, Command3),
		atom_concat(Command3, '"', Command),
		^^command(Command, registry_archive_uncompress_failed(Registry, OSPath)).

	installed_registry_packs(Registry) :-
		expand_library_path(logtalk_packs(packs), Directory),
		directory_files(Directory, Packs, [type(directory), dot_files(false), paths(absolute)]),
		member(Pack, Packs),
		path_concat(Pack, 'REGISTRY.packs', File),
		open(File, read, Stream),
		read(Stream, PackRegistry),
		close(Stream),
		PackRegistry == Registry,
		!.

	make_registry_installation_directory(Registry, Path, OSPath) :-
		expand_library_path(logtalk_packs(registries), Registries),
		path_concat(Registries, Registry, Path),
		internal_os_path(Path, OSPath),
		make_directory_path(Path).

:- end_object.