-- Gives every new (anonymous) user a realistic history so the app never opens empty:
--   * ~3 months of daily reviews following a 27–29 day cycle (period, mood, journal), each period logged in full
--   * programs 4x a week from 6 weeks ago to 3 weeks ahead, past ones mostly ticked off
--   * workout journals on some completed program days
-- Dates are relative to signup day in Sydney time, so "today" lines up with the app.

create or replace function public.seed_demo_data(target_user uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_today date := (now() at time zone 'Australia/Sydney')::date;
    -- Period start days (newest first) and how long each lasted. Slightly uneven, like a real cycle.
    -- The latest start is 9 days ago, so today is follicular. The app predicts the next period a
    -- cycle after that start, so the calendar shows it ~19 days out.
    v_starts date[] := array[v_today - 9, v_today - 37, v_today - 66, v_today - 93];
    v_lengths int[] := array[5, 5, 6, 4];

    v_conditioning jsonb := $json$[
        {"duration": 45, "workouts": [["Goblet Squat",4,10,60],["Romanian Deadlift",3,10,60],["Dumbbell Row",3,12,45],["Push-up",3,12,45],["Jump Rope",null,null,null]]},
        {"duration": 40, "workouts": [["Kettlebell Swing",4,15,45],["Bulgarian Split Squat",3,8,60],["Dumbbell Bench Press",3,10,60],["Mountain Climbers",3,20,30],["Rowing Machine",null,null,null]]},
        {"duration": 50, "workouts": [["Hip Thrust",4,10,60],["Step-Up",3,10,45],["Lat Pull-down",3,12,45],["Farmer's Walk",3,null,60],["Burpees",3,10,45]]}
    ]$json$;
    v_physio jsonb := $json$[
        {"duration": 30, "workouts": [["Glute Bridge",3,12,30],["Bird Dog",3,10,30],["Side Planks",3,null,30],["Pallof Press",3,10,30]]},
        {"duration": 25, "workouts": [["Superman",3,12,30],["Wall Sit",3,null,45],["Donkey Kicks",3,15,30],["Walking",null,null,null]]},
        {"duration": 35, "workouts": [["Nordic Hamstring Curl",3,6,60],["Single-Leg Romanian Deadlift",3,8,45],["Calf Raise",3,15,30],["Planks",3,null,30],["Back Extension",3,12,30]]}
    ]$json$;

    v_workout_notes text[] := array[
        'Legs felt heavy at the start but warmed up by the second set.',
        'Upped the weight on the squats, form held up.',
        'Short on breath in the last round, need to pace better.',
        'Felt really strong today, best session this week.',
        'Took longer rests than planned. Still got it done.',
        'Hamstrings tight, did extra stretching after.'
    ];

    v_day date;
    v_dow int;
    v_idx int := 0;
    v_tpl jsonb;
    v_is_physio boolean;
    v_program uuid;
    v_count int;
    v_roll double precision;
    v_trained_days date[] := '{}';
    v_workout_journals jsonb := '{}';

    v_start date;
    v_len int;
    v_cycle_day int;
    v_on_period boolean;
    v_trained boolean;
    v_emotions text[];
    v_journals text[];
    v_intensity int;
    v_journal text;
begin
    -- Programs: Mon/Fri conditioning, Wed/Sat physio.
    for v_day in select generate_series(v_today - 42, v_today + 21, interval '1 day')::date loop
        v_dow := extract(isodow from v_day);
        continue when v_dow not in (1, 3, 5, 6);

        v_idx := v_idx + 1;
        v_is_physio := v_dow in (3, 6);
        v_tpl := case when v_is_physio then v_physio else v_conditioning end -> (v_idx % 3);
        v_count := jsonb_array_length(v_tpl -> 'workouts');
        v_program := gen_random_uuid();

        insert into public.exercise_programs
            (id, user_id, date, day, exercise_duration, number_of_exercises, exercise_type)
        values (
            v_program,
            target_user,
            (v_day + case when v_is_physio then time '07:30' else time '17:30' end) at time zone 'Australia/Sydney',
            v_idx,
            (v_tpl ->> 'duration')::int,
            v_count,
            case when v_is_physio then 'physio' else 'conditioningTraining' end
        );

        insert into public.workouts (program_id, name, sets, reps, rest_seconds, position)
        select v_program, w ->> 0, (w ->> 1)::int, (w ->> 2)::int, (w ->> 3)::int, (ord - 1)::int
        from jsonb_array_elements(v_tpl -> 'workouts') with ordinality as t(w, ord);

        -- Past sessions: most done in full, some cut short, a few skipped. Today and later stay open.
        continue when v_day >= v_today;
        v_roll := random();
        continue when v_roll >= 0.93;

        insert into public.workout_completions (user_id, workout_id, completed_at)
        select target_user, w.id,
               (v_day + time '09:00') at time zone 'Australia/Sydney' + make_interval(mins => (v_tpl ->> 'duration')::int)
        from public.workouts w
        where w.program_id = v_program
          and (v_roll < 0.8 or w.position < v_count - 1);

        v_trained_days := v_trained_days || v_day;
        if random() < 0.5 then
            v_workout_journals := v_workout_journals || jsonb_build_object(
                v_day::text,
                jsonb_build_object('workout_journal:' || upper(v_program::text),
                                   v_workout_notes[1 + floor(random() * array_length(v_workout_notes, 1))::int]));
        end if;
    end loop;

    -- Daily reviews from the oldest period start up to yesterday (today is left for the user to fill in).
    -- Starting at that period, not a round 90 days, keeps it whole; a clipped one would drag down
    -- the average period length the calendar predicts with.
    for v_day in select generate_series(v_starts[array_length(v_starts, 1)], v_today - 1, interval '1 day')::date loop
        select s, l into v_start, v_len
        from unnest(v_starts, v_lengths) as c(s, l)
        where s <= v_day
        order by s desc
        limit 1;

        v_cycle_day := v_day - v_start + 1;
        v_on_period := v_cycle_day <= v_len;
        v_trained := v_day = any(v_trained_days)
                     or (v_day < v_today - 42 and not v_on_period and random() < 0.55);

        -- Real users miss days, but period and training days are almost always logged.
        continue when not v_on_period and not v_trained and random() < 0.35;

        if v_on_period and v_cycle_day <= 2 then
            v_emotions := array['sad', 'stressed', 'neutral'];
            v_intensity := 1 + floor(random() * 2)::int;
            v_journals := array['Bad cramps today, heat pack all afternoon.',
                                'Period started. Tired and bloated.',
                                'Low energy, went to bed early.'];
        elsif v_on_period then
            v_emotions := array['neutral', 'calm', 'sad'];
            v_intensity := 2;
            v_journals := array['Cramps easing off, feeling more like myself.',
                                'Light day, did some stretching.'];
        elsif v_cycle_day <= 13 then
            v_emotions := array['happy', 'calm', 'happy'];
            v_intensity := 3 + floor(random() * 2)::int;
            v_journals := array['Lots of energy today!',
                                'Good sleep, felt motivated all day.',
                                'Caught up with friends after training, great day.'];
        elsif v_cycle_day <= 16 then
            v_emotions := array['happy', 'happy', 'calm'];
            v_intensity := 4;
            v_journals := array['Feeling confident and strong.',
                                'Best mood all month honestly.'];
        elsif v_cycle_day <= 23 then
            v_emotions := array['calm', 'neutral', 'happy'];
            v_intensity := 2 + floor(random() * 2)::int;
            v_journals := array['Pretty steady day.',
                                'A bit more hungry than usual.',
                                'Busy with uni, squeezed in some movement.'];
        else
            v_emotions := array['stressed', 'neutral', 'sad'];
            v_intensity := 1 + floor(random() * 2)::int;
            v_journals := array['Moody and irritable, PMS kicking in.',
                                'Bloated and tired, skin breaking out.',
                                'Craving chocolate. Period must be close.'];
        end if;

        v_journal := case when random() < 0.45
                          then v_journals[1 + floor(random() * array_length(v_journals, 1))::int]
                          else '' end;

        insert into public.daily_reviews (user_id, day, answers, emotion, intensity, journal)
        values (
            target_user,
            v_day,
            jsonb_build_object(
                'trained', case when v_trained then 'yes' else 'no' end,
                'onPeriod', case when v_on_period then 'yes' else 'no' end,
                'informCoachPeriod', case when v_on_period and v_cycle_day = 1 then 'yes' else 'no' end,
                'informCoachWorkout', case when v_trained and random() < 0.4 then 'yes' else 'no' end
            ) || coalesce(v_workout_journals -> v_day::text, '{}'::jsonb),
            v_emotions[1 + floor(random() * array_length(v_emotions, 1))::int],
            v_intensity,
            v_journal
        )
        on conflict (user_id, day) do nothing;
    end loop;
end;
$$;

create or replace function public.handle_new_user_demo_data()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    -- Seeding must never block a sign-up; on failure the user just starts empty.
    begin
        perform public.seed_demo_data(new.id);
    exception when others then
        raise warning 'seed_demo_data failed for %: %', new.id, sqlerrm;
    end;
    return new;
end;
$$;

-- Only the trigger may run these; clients must not seed data into arbitrary users via RPC.
revoke execute on function public.seed_demo_data(uuid) from public, anon, authenticated;
revoke execute on function public.handle_new_user_demo_data() from public, anon, authenticated;

drop trigger if exists on_auth_user_created_seed_demo on auth.users;
create trigger on_auth_user_created_seed_demo
    after insert on auth.users
    for each row execute function public.handle_new_user_demo_data();
