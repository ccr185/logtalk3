%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  This file is part of Logtalk <https://logtalk.org/>
%  Copyright 1998-2020 Paulo Moura <pmoura@logtalk.org>
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


:- object(tests,
	extends(lgtunit)).

	:- info([
		version is 1.2,
		author is 'Paulo Moura',
		date is 2019/12/30,
		comment is 'Unit tests for the "cascade" example.'
	]).

	cover(cascade).
	cover(cascade_dcgs).

	test(cascade_01) :-
		catch(cascade::process_image(image, Final), Error, true),
		(	var(Error) ->
			Final == with_rainbow(smaller(sparkling_eyes(with_bow_tie(cropped(image)))))
		;	ground(Error),
			list::memberchk(Error, [missing_cat,bow_tie_failure,eyes_closed,wants_to_grow,sunny_day])
		).

	test(cascade_dcgs_01) :-
		catch(cascade_dcgs::process_image(image, Final), Error, true),
		(	var(Error) ->
			Final == with_rainbow(smaller(sparkling_eyes(with_bow_tie(cropped(image)))))
		;	ground(Error),
			list::memberchk(Error, [missing_cat,bow_tie_failure,eyes_closed,wants_to_grow,sunny_day])
		).

:- end_object.
