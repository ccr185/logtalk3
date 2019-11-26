%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  This file is part of Logtalk <https://logtalk.org/>
%  Copyright 2017 Sergio Castro <sergioc78@gmail.com> and
%  Paulo Moura <pmoura@logtalk.org>
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


:- object(optional).

	:- info([
		version is 1.5,
		author is 'Paulo Moura',
		date is 2019/11/26,
		comment is 'Constructors for optional terms. An optional term is either empty or holds a value. Optional terms should be regarded as opaque terms and always used with the ``optional/1`` object by passing the optional term as a parameter.',
		remarks is [
			'Type-checking support' - 'This object also defines a type ``optional`` for use with the ``type`` library object.'
		],
		see_also is [optional(_), type]
	]).

	:- public(empty/1).
	:- mode(empty(--nonvar), one).
	:- info(empty/1, [
		comment is 'Constructs an empty optional term.',
		argnames is ['Optional']
	]).

	:- public(of/2).
	:- mode(of(@term, --nonvar), one).
	:- info(of/2, [
		comment is 'Constructs an optional term holding the given value.',
		argnames is ['Value', 'Optional']
	]).

	:- public(from_goal/3).
	:- meta_predicate(from_goal(0, *, *)).
	:- mode(from_goal(+callable, --term, --nonvar), one).
	:- info(from_goal/3, [
		comment is 'Constructs an optional term holding a value bound by calling the given goal. Returns an empty optional term if the goal fails or throws an error.',
		argnames is ['Goal', 'Value', 'Optional']
	]).

	empty(empty).

	of(Term, optional(Term)).

	from_goal(Goal, Value, Optional) :-
		(	catch(Goal, Error, true) ->
			(	var(Error) ->
				Optional = optional(Value)
			;	Optional = empty
			)
		;	Optional = empty
		).

	:- multifile(type::type/1).
	% workaround the lack of support for static multifile predicates in Qu-Prolog
	:- if(current_logtalk_flag(prolog_dialect, qp)).
		:- dynamic(type::type/1).
	:- endif.

	% clauses for the type::type/1 predicate must always be defined with
	% an instantiated first argument to keep calls deterministic by taking
	% advantage of first argument indexing
	type::type(optional).

	:- multifile(type::check/2).
	% workaround the lack of support for static multifile predicates in Qu-Prolog
	:- if(current_logtalk_flag(prolog_dialect, qp)).
		:- dynamic(type::check/2).
	:- endif.

	% clauses for the type::check/2 predicate must always be defined with
	% an instantiated first argument to keep calls deterministic by taking
	% advantage of first argument indexing
	type::check(optional, Term) :-
		(	var(Term) ->
			throw(instantiation_error)
		;	Term == empty ->
			true
		;	Term = optional(_) ->
			true
		;	throw(type_error(optional, Term))
		).

:- end_object.


:- object(optional(_Optional)).

	:- info([
		version is 1.7,
		author is 'Paulo Moura',
		date is 2019/11/26,
		comment is 'Optional term handling predicates. Requires passing an optional term (constructed using the ``optional`` object predicates) as a parameter.',
		parnames is ['Optional'],
		see_also is [optional]
	]).

	:- public(is_empty/0).
	:- mode(is_empty, zero_or_one).
	:- info(is_empty/0, [
		comment is 'True if the optional term is empty. See also the ``if_empty/1`` predicate.'
	]).

	:- public(is_present/0).
	:- mode(is_present, zero_or_one).
	:- info(is_present/0, [
		comment is 'True if the optional term holds a value. See also the ``if_present/1`` predicate.'
	]).

	:- public(if_empty/1).
	:- meta_predicate(if_empty(0)).
	:- mode(if_empty(+callable), zero_or_more).
	:- info(if_empty/1, [
		comment is 'Calls a goal if the optional term is empty. Succeeds otherwise.',
		argnames is ['Goal']
	]).

	:- public(if_present/1).
	:- meta_predicate(if_present(1)).
	:- mode(if_present(+callable), zero_or_more).
	:- info(if_present/1, [
		comment is 'Applies a closure to the value hold by the optional term if not empty. Succeeds otherwise.',
		argnames is ['Closure']
	]).

	:- public(if_present_or_else/2).
	:- meta_predicate(if_present_or_else(1, 0)).
	:- mode(if_present_or_else(+callable, +callable), zero_or_more).
	:- info(if_present_or_else/2, [
		comment is 'Applies a closure to the value hold by the optional term if not empty. Otherwise calls the given goal.',
		argnames is ['Closure', 'Goal']
	]).

	:- public(filter/2).
	:- meta_predicate(filter(1, *)).
	:- mode(filter(+callable, --nonvar), one).
	:- info(filter/2, [
		comment is 'Returns the optional term when it is not empty and the value it holds satisfies a closure. Otherwise returns an empty optional term.',
		argnames is ['Closure', 'NewOptional']
	]).

	:- public(map/2).
	:- meta_predicate(map(2, *)).
	:- mode(map(+callable, --nonvar), one).
	:- info(map/2, [
		comment is 'When the optional term is not empty and mapping a closure with the value it holds and the new value as additional arguments is successful, returns an optional term with the new value. Otherwise returns an empty optional term.',
		argnames is ['Closure', 'NewOptional']
	]).

	:- public(flat_map/2).
	:- meta_predicate(flat_map(2, *)).
	:- mode(flat_map(+callable, --nonvar), one).
	:- info(flat_map/2, [
		comment is 'When the optional term is not empty and mapping a closure with the value it holds and the new optional term as additional arguments is successful, returns the new optional term. Otherwise returns an empty optional term.',
		argnames is ['Closure', 'NewOptional']
	]).

	:- public(or/2).
	:- meta_predicate(or(*, 1)).
	:- mode(or(--term, @callable), zero_or_one).
	:- info(or/2, [
		comment is 'Returns the same optional term if not empty. Otherwise calls closure to generate a new optional term. Fails if optional term is empty and calling the closure fails or throws an error.',
		argnames is ['NewOptional', 'Closure']
	]).

	:- public(get/1).
	:- mode(get(--term), one_or_error).
	:- info(get/1, [
		comment is 'Returns the value hold by the optional term if not empty. Throws an error otherwise.',
		argnames is ['Value'],
		exceptions is ['Optional is empty' - existence_error(optional_term,'Optional')]
	]).

	:- public(or_else/2).
	:- mode(or_else(--term, @term), one).
	:- info(or_else/2, [
		comment is 'Returns the value hold by the optional term if not empty or the given default value if the optional term is empty.',
		argnames is ['Value', 'Default']
	]).

	:- public(or_else_get/2).
	:- meta_predicate(or_else_get(*, 1)).
	:- mode(or_else_get(--term, +callable), one_or_error).
	:- info(or_else_get/2, [
		comment is 'Returns the value hold by the optional term if not empty. Applies a closure to compute the value otherwise. Throws an error when the optional term is empty and the value cannot be computed.',
		argnames is ['Value', 'Closure'],
		exceptions is ['Optional is empty and the term cannot be computed' - existence_error(optional_term,'Optional')]
	]).

	:- public(or_else_call/2).
	:- meta_predicate(or_else_call(*, 0)).
	:- mode(or_else_call(--term, +callable), zero_or_one).
	:- info(or_else_call/2, [
		comment is 'Returns the value hold by the optional term if not empty or calls a goal deterministically if the optional term is empty.',
		argnames is ['Value', 'Goal']
	]).

	:- public(or_else_fail/1).
	:- mode(or_else_fail(--term), zero_or_one).
	:- info(or_else_fail/1, [
		comment is 'Returns the value hold by the optional term if not empty. Fails otherwise. Usually called to skip over empty optional terms.',
		argnames is ['Value']
	]).

	:- public(or_else_throw/2).
	:- mode(or_else_throw(--term, @nonvar), one_or_error).
	:- info(or_else_throw/2, [
		comment is 'Returns the value hold by the optional term if not empty. Throws the given error otherwise.',
		argnames is ['Value', 'Error']
	]).

	is_empty :-
		parameter(1, empty).

	is_present :-
		parameter(1, optional(_)).

	if_empty(Goal) :-
		parameter(1, Optional),
		(	Optional == empty ->
			call(Goal)
		;	true
		).

	if_present(Closure) :-
		parameter(1, Optional),
		(	Optional == empty ->
			true
		;	Optional = optional(Term),
			call(Closure, Term)
		).

	if_present_or_else(Closure, Goal) :-
		parameter(1, Optional),
		(	Optional == empty ->
			call(Goal)
		;	Optional = optional(Value),
			call(Closure, Value)
		).

	filter(Closure, NewOptional) :-
		parameter(1, Optional),
		(	Optional = optional(Value),
			call(Closure, Value) ->
			NewOptional = Optional
		;	NewOptional = empty
		).

	map(Closure, NewOptional) :-
		parameter(1, Optional),
		(	Optional = optional(Value),
			catch(call(Closure, Value, NewValue), _, fail) ->
			NewOptional = optional(NewValue)
		;	NewOptional = empty
		).

	flat_map(Closure, NewOptional) :-
		parameter(1, Optional),
		(	Optional = optional(Value),
			catch(call(Closure, Value, NewOptional), _, fail) ->
			true
		;	NewOptional = empty
		).

	or(NewOptional, Closure) :-
		parameter(1, Optional),
		(	Optional = optional(_) ->
			NewOptional = Optional
		;	catch(call(Closure, NewOptional), _, fail)
		).

	get(Value) :-
		parameter(1, Optional),
		(	Optional == empty ->
			existence_error(optional_term, Optional)
		;	Optional = optional(Value)
		).

	or_else(Value, Default) :-
		parameter(1, Optional),
		(	Optional == empty ->
			Value = Default
		;	Optional = optional(Value)
		).

	or_else_get(Value, Closure) :-
		parameter(1, Optional),
		(	Optional = optional(Value) ->
			true
		;	catch(call(Closure, Value), _, existence_error(optional_term,Optional)) ->
			true
		;	existence_error(optional_term, Optional)
		).

	or_else_call(Value, Goal) :-
		parameter(1, Optional),
		(	Optional == empty ->
			once(Goal)
		;	Optional = optional(Value)
		).

	or_else_fail(Value) :-
		parameter(1, optional(Value)).

	or_else_throw(Value, Error) :-
		parameter(1, Optional),
		(	Optional = optional(Value) ->
			true
		;	throw(Error)
		).

:- end_object.
