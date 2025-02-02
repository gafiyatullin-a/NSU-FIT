CREATE OR REPLACE procedure repertoire_info(from_date_show IN DATE,
                                            to_date_show IN DATE,
                                            first_time_show IN INT,
                                            id_show IN "Show"."id_show"%TYPE,
                                            status IN INT,
                                            from_century_show IN INT,
                                            to_century_show IN INT,
                                            id_conductor IN "Show"."id_conductor"%TYPE,
                                            id_production_designer IN "Show"."id_production_designer"%TYPE,
                                            id_director IN "Show"."id_director"%TYPE,
                                            id_genre IN "Show"."id_genre"%TYPE,
                                            id_age_category IN "Show"."id_age_category"%TYPE,
                                            id_author IN "Show"."id_author"%TYPE,
                                            id_country IN "Author"."id_country"%TYPE,
                                            show_cur OUT SYS_REFCURSOR)
    is
begin
    open show_cur for
        select "id_show",
               "name_show"                                                               as "Название",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_director")                                     as "Режиссер",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_conductor")                                    as "Диpижеp",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_production_designer")                          as "Художник",
               ("name_author" || ' ' || "surname_author" || ' ' || "middle_name_author") as "Автор",
               "name_genre"                                                              as "Жанр",
               "century_show"                                                            as "Век спектакля",
               "premier_date_show"                                                       as "Дата премьеры",
               "name_age_category"                                                       as "Возраст"
        from (("Show" inner join "Author" using ("id_author"))
            inner join "Genre" using ("id_genre"))
                 inner join "Age_category" using ("id_age_category")
        where "id_show" in (select "id_show"
                            from (("Repertoire" inner join "Show" using ("id_show"))
                                     inner join "Author" using ("id_author"))
                            where ("performance_date_repertoire" <= NVL(to_date_show, "performance_date_repertoire")
                                and "performance_date_repertoire" >= NVL(from_date_show, "performance_date_repertoire")
                                and ((status = 0) or "performance_date_repertoire" <= (select CURRENT_DATE from dual)))
                              and "id_show" = NVL(id_show, "id_show")
                              and "century_show" <= NVL(to_century_show, "century_show")
                              and "century_show" >= NVL(from_century_show, "century_show")
                              and "id_conductor" = NVL(id_conductor, "id_conductor")
                              and "id_production_designer" = NVL(id_production_designer, "id_production_designer")
                              and "id_director" = NVL(id_director, "id_director")
                              and "id_genre" = NVL(id_genre, "id_genre")
                              and "id_age_category" = NVL(id_age_category, "id_age_category")
                              and "id_author" = NVL(id_author, "id_author")
                              and "id_country" = NVL(id_country, "id_country")
                            group by "id_show"
                            having first_time_show = 0
                                or (first_time_show != 0 and count(*) = 1));
end;
/

CREATE OR REPLACE procedure show_info(id_show IN "Show"."id_show"%TYPE,
                                      show_cur OUT SYS_REFCURSOR)
    is
begin
    open show_cur for
        select "id_show",
               "name_show"                                                               as "Название",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_director")                                     as "Режиссер",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_conductor")                                    as "Диpижеp",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_production_designer")                          as "Художник",
               ("name_author" || ' ' || "surname_author" || ' ' || "middle_name_author") as "Автор",
               "name_genre"                                                              as "Жанр",
               "century_show"                                                            as "Век спектакля",
               "premier_date_show"                                                       as "Дата премьеры",
               "name_age_category"                                                       as "Возраст"
        from (("Show" inner join "Author" using ("id_author"))
            inner join "Genre" using ("id_genre"))
                 inner join "Age_category" using ("id_age_category")
        where "id_show" = id_show;
end;
/

CREATE OR REPLACE procedure author_info(name_author IN "Author"."name_author"%TYPE,
                                        surname_author IN "Author"."surname_author"%TYPE,
                                        middle_name_author IN "Author"."middle_name_author"%TYPE,
                                        from_century_life IN INT,
                                        to_century_life IN INT,
                                        id_country IN "Author"."id_country"%TYPE,
                                        author_cur OUT SYS_REFCURSOR)
    is
begin
    open author_cur for
        select "id_author",
               "name_author"         as "Имя",
               "surname_author"      as "Фаммлия",
               "middle_name_author"  as "Отчество",
               "life_century_author" as "Век жизни",
               "name_country"        as "Страна"
        from ("Author"
                 inner join "Country" using ("id_country"))
        where ("name_author" like '%' || name_author || '%' or name_author is null)
          and ("surname_author" like '%' || surname_author || '%' or surname_author is null)
          and ("middle_name_author" like '%' || middle_name_author || '%' or middle_name_author is null)
          and "life_century_author" >= NVL(from_century_life, "life_century_author")
          and "life_century_author" <= NVL(to_century_life, "life_century_author")
          and "id_country" = NVL(id_country, "id_country");
end;
/

CREATE OR REPLACE procedure author_insert(name IN "Author"."name_author"%TYPE,
                                          surname IN "Author"."surname_author"%TYPE,
                                          middle_name IN "Author"."middle_name_author"%TYPE,
                                          century IN "Author"."life_century_author"%TYPE,
                                          country IN "Author"."id_country"%TYPE)
    is
begin
    INSERT INTO "Author"("id_author", "name_author", "surname_author", "middle_name_author", "life_century_author",
                         "id_country")
    VALUES (0, name, surname, middle_name, century, country);

    COMMIT;
end;
/

CREATE OR REPLACE procedure author_update(name IN "Author"."name_author"%TYPE,
                                          surname IN "Author"."surname_author"%TYPE,
                                          middle_name IN "Author"."middle_name_author"%TYPE,
                                          century IN "Author"."life_century_author"%TYPE,
                                          country IN "Author"."id_country"%TYPE,
                                          id_author IN "Author"."id_author"%TYPE)
    is
begin
    UPDATE "Author"
    SET "name_author"         = name,
        "surname_author"      = surname,
        "middle_name_author"  = middle_name,
        "life_century_author" = century,
        "id_country"          = country
    WHERE "id_author" = id_author;

    COMMIT;
end;
/

CREATE OR REPLACE procedure author_delete(id_author IN "Author"."id_author"%TYPE)
    is
begin
    DELETE FROM "Author" WHERE "id_author" = id_author;

    COMMIT;
end;
/

CREATE OR REPLACE procedure author_shows(from_date_show IN "Repertoire"."performance_date_repertoire"%TYPE,
                                         to_date_show IN "Repertoire"."performance_date_repertoire"%TYPE,
                                         id_genre IN "Genre"."id_genre"%TYPE,
                                         id_author IN "Author"."id_author"%TYPE,
                                         show_cur OUT SYS_REFCURSOR)
    is
begin
    open show_cur for
        select "id_show",
               "name_show"                                                               as "Название",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_director")                                     as "Режиссер",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_conductor")                                    as "Диpижеp",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_production_designer")                          as "Художник",
               ("name_author" || ' ' || "surname_author" || ' ' || "middle_name_author") as "автор",
               "name_genre"                                                              as "Жанр",
               "century_show"                                                            as "Век спектакля",
               "premier_date_show"                                                       as "Дата премьеры"
        from (("Show" inner join "Author" using ("id_author"))
                 inner join "Genre" using ("id_genre"))
        where "id_show" in (select "id_show"
                            from (("Repertoire" inner join "Show" using ("id_show"))
                                     inner join "Author" using ("id_author"))
                            where ("performance_date_repertoire" <= NVL(to_date_show, "performance_date_repertoire")
                                and "performance_date_repertoire" >= NVL(from_date_show, "performance_date_repertoire")
                                and "id_genre" = NVL(id_genre, "id_genre")
                                and "id_author" = NVL(id_author, "id_author"))
                            group by "id_show");
end;
/

CREATE OR REPLACE procedure actors_roles_in_show_info(id_show IN "Show"."id_show"%TYPE,
                                                      list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_employee",
               "id_role",
               ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as "Актер",
               "name_role"                                                                     as "Роль",
               (select 'Нет' from dual where "is_understudy_direction" = 0)
                   || (select 'Да' from dual where "is_understudy_direction" != 0)             as "Дублер"
        from ("Direction" inner join "Employee" on "id_actor" = "id_employee")
                 inner join "Role" using ("id_role")
        where "id_show" = id_show;
end;
/

CREATE OR REPLACE procedure musicians_in_show_info(id_show IN "Show"."id_show"%TYPE,
                                                   list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as "Музыкант",
               "name_instrument"                                                               as "Инструмент"
        from (("Musician-Show" inner join "Employee" on "id_musician" = "id_employee")
            inner join "Musician-Instrument" using ("id_musician"))
                 inner join "Musical_instruments" using ("id_instrument")
        where "id_show" = id_show;
end;
/

CREATE OR REPLACE procedure get_genders_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_gender", "name_gender"
        from "Gender";
end;
/

CREATE OR REPLACE procedure get_education_list(
    list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_education", "name_education"
        from "Education";
end;
/

CREATE OR REPLACE procedure get_job_types_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_job_type", "name_job_type"
        from "Job_types";
end;
/

CREATE OR REPLACE function is_sub_job_type(id_parent_job_type IN "Job_types"."id_parent_job_type"%TYPE,
                                           id_job_type IN "Job_types"."id_job_type"%TYPE)
    return int
    is
    cursor job_cur is
        select "id_job_type"
        from "Job_types"
        where "id_parent_job_type" = id_parent_job_type;
    result int;
begin
    if id_parent_job_type = id_job_type then
        return 1;
    end if;

    for job_rec in job_cur
        loop
            if job_rec."id_job_type" = id_job_type then
                return 1;
            else
                result := is_sub_job_type(job_rec."id_job_type", id_job_type);
                if result = 1 then
                    return 1;
                end if;
            end if;
        end loop;

    return 0;
end;
/

CREATE OR REPLACE procedure employee_info(id_employee IN "Employee"."id_employee"%TYPE,
                                          name IN "Employee"."name_employee"%TYPE,
                                          surname IN "Employee"."surname_employee"%TYPE,
                                          middle_name IN "Employee"."middle_name_employee"%TYPE,
                                          id_gender IN "Employee"."id_gender"%TYPE,
                                          birthday_from IN "Employee"."birthday_employee"%TYPE,
                                          birthday_to IN "Employee"."birthday_employee"%TYPE,
                                          age_from IN INT,
                                          age_to IN INT,
                                          experience_from IN INT,
                                          experience_to IN INT,
                                          children_amount_from IN "Employee"."children_amount_employee"%TYPE,
                                          children_amount_to IN "Employee"."children_amount_employee"%TYPE,
                                          salary_from IN "Employee"."salary_employee"%TYPE,
                                          salary_to IN "Employee"."salary_employee"%TYPE,
                                          id_education IN "Employee"."id_education"%TYPE,
                                          id_job_type IN "Employee"."id_job_type"%TYPE,
                                          employee_cur OUT SYS_REFCURSOR)
    is
begin
    open employee_cur for
        select "id_employee",
               "name_employee"            as "Имя",
               "surname_employee"         as "Фамилия",
               "middle_name_employee"     as "Отчество",
               "name_gender"              as "Гендер",
               "birthday_employee"        as "Дата рождения",
               "hire_date_employee"       as "Дата найма",
               "children_amount_employee" as "Кол-во детей",
               "salary_employee"          as "Зарплата(руб.)",
               "name_education"           as "Образование",
               "name_job_type"            as "Должность"
        from ((("Employee" inner join "Education" using ("id_education"))
            inner join "Gender" using ("id_gender"))
                 inner join "Job_types" using ("id_job_type"))
        where (id_employee is not null and "id_employee" = id_employee)
           or (id_employee is null and
               (("name_employee" like '%' || name || '%' or name is null)
                   and ("surname_employee" like '%' || surname || '%' or surname is null)
                   and ("middle_name_employee" like '%' || middle_name || '%' or middle_name is null)
                   and "id_gender" = NVL(id_gender, "id_gender")
                   and "birthday_employee" >= NVL(birthday_from, "birthday_employee")
                   and "birthday_employee" <= NVL(birthday_to, "birthday_employee")
                   and TRUNC(((SELECT SYSDATE FROM DUAL) - "hire_date_employee")) >= NVL(experience_from,
                                                                                         TRUNC(((SELECT SYSDATE FROM DUAL) - "hire_date_employee")))
                   and TRUNC(((SELECT SYSDATE FROM DUAL) - "hire_date_employee")) <= NVL(experience_to,
                                                                                         TRUNC(((SELECT SYSDATE FROM DUAL) - "hire_date_employee")))
                   and TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")) >= NVL(age_from,
                                                                                        TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")))
                   and TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")) <= NVL(age_to,
                                                                                        TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")))
                   and "children_amount_employee" >= NVL(children_amount_from, "children_amount_employee")
                   and "children_amount_employee" <= NVL(children_amount_to, "children_amount_employee")
                   and "salary_employee" >= NVL(salary_from, "salary_employee")
                   and "salary_employee" <= NVL(salary_to, "salary_employee")
                   and "id_education" = NVL(id_education, "id_education")
                   and (id_job_type is null or is_sub_job_type(id_job_type, "id_job_type") = 1)));
end;
/

CREATE OR REPLACE procedure employee_insert(name IN "Employee"."name_employee"%TYPE,
                                            surname IN "Employee"."surname_employee"%TYPE,
                                            middle_name IN "Employee"."middle_name_employee"%TYPE,
                                            id_gender IN "Employee"."id_gender"%TYPE,
                                            birthday IN "Employee"."birthday_employee"%TYPE,
                                            hire_date IN "Employee"."hire_date_employee"%TYPE,
                                            children_amount IN "Employee"."children_amount_employee"%TYPE,
                                            salary IN "Employee"."salary_employee"%TYPE,
                                            id_education IN "Employee"."id_education"%TYPE,
                                            id_job_type IN "Employee"."id_job_type"%TYPE)
    is
begin
    INSERT INTO "Employee"
    VALUES (0, name, surname, middle_name, id_gender, birthday, hire_date, children_amount, salary,
            id_education, id_job_type);

    COMMIT;
end;
/

CREATE OR REPLACE procedure employee_update(name IN "Employee"."name_employee"%TYPE,
                                            surname IN "Employee"."surname_employee"%TYPE,
                                            middle_name IN "Employee"."middle_name_employee"%TYPE,
                                            id_gender IN "Employee"."id_gender"%TYPE,
                                            birthday IN "Employee"."birthday_employee"%TYPE,
                                            hire_date IN "Employee"."hire_date_employee"%TYPE,
                                            children_amount IN "Employee"."children_amount_employee"%TYPE,
                                            salary IN "Employee"."salary_employee"%TYPE,
                                            id_education IN "Employee"."id_education"%TYPE,
                                            id_job_type IN "Employee"."id_job_type"%TYPE,
                                            id_employee IN "Employee"."id_employee"%TYPE)
    is
begin
    UPDATE "Employee"
    SET "name_employee"            = NVL(name, "name_employee"),
        "surname_employee"         = NVL(surname, "surname_employee"),
        "middle_name_employee"     = NVL(middle_name, "middle_name_employee"),
        "id_gender"                = NVL(id_gender, "id_gender"),
        "birthday_employee"        = NVL(birthday, "birthday_employee"),
        "hire_date_employee"       = NVL(hire_date, "hire_date_employee"),
        "children_amount_employee" = NVL(children_amount, "children_amount_employee"),
        "salary_employee"          = NVL(salary, "salary_employee"),
        "id_education"             = NVL(id_education, "id_education"),
        "id_job_type"              = id_job_type
    WHERE "id_employee" = id_employee;

    COMMIT;
end;
/

CREATE OR REPLACE procedure employee_delete(id_employee IN "Employee"."id_employee"%TYPE)
    is
begin
    DELETE FROM "Employee" WHERE "id_employee" = id_employee;

    COMMIT;
end;
/

CREATE OR REPLACE procedure get_shows_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_show", "name_show"
        from "Show";
end;
/

CREATE OR REPLACE procedure get_genres_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_genre", "name_genre"
        from "Genre";
end;
/

CREATE OR REPLACE procedure get_age_categories_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_age_category", "name_age_category"
        from "Age_category";
end;
/

CREATE OR REPLACE procedure get_authors_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_author", ("name_author" || ' ' || "surname_author" || ' ' || "middle_name_author") as "name_author"
        from "Author";
end;
/

CREATE OR REPLACE procedure get_countries_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_country", "name_country"
        from "Country";
end;
/

CREATE OR REPLACE procedure get_employees_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_employee", ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as name
        from "Employee";
end;
/

CREATE OR REPLACE procedure get_conductors_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_employee", ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as name
        from ("Employee"
                 inner join "Job_types" using ("id_job_type"))
        where "name_job_type" like 'диpижеp-постановщик';
end;
/

CREATE OR REPLACE procedure get_designers_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_employee", ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as name
        from ("Employee"
                 inner join "Job_types" using ("id_job_type"))
        where "name_job_type" like 'художник-постановщик';
end;
/

create or replace procedure get_directors_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_employee", ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as name
        from ("Employee"
                 inner join "Job_types" using ("id_job_type"))
        where "name_job_type" like 'pежиссеp-постановщик';
end;
/

CREATE OR REPLACE procedure get_actors_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_employee", ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as name
        from ("Employee"
                 inner join "Job_types" using ("id_job_type"))
        where "name_job_type" like 'актер';
end;
/

CREATE OR REPLACE procedure get_rank_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_rank", "name_rank"
        from "Rank";
end;
/

CREATE OR REPLACE procedure get_competitions_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_competition", "name_competition"
        from "Competition";
end;
/

CREATE OR REPLACE procedure actor_rank_info(id_actor IN "Employee"."id_employee"%TYPE,
                                            id_gender IN "Employee"."id_gender"%TYPE,
                                            age_from IN INT,
                                            age_to IN INT,
                                            date_from IN "Actor-Rank"."obtaining_date_actor_rank"%TYPE,
                                            date_to IN "Actor-Rank"."obtaining_date_actor_rank"%TYPE,
                                            id_rank IN "Rank"."id_rank"%TYPE,
                                            id_competition IN "Competition"."id_competition"%TYPE,
                                            actor_rank_cur OUT SYS_REFCURSOR)
    is
begin
    open actor_rank_cur for
        select "name_rank"                                                                     as "Звание",
               "name_competition"                                                              as "Конкурс",
               "obtaining_date_actor_rank"                                                     as "Дата получения",
               ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as "Актер"
        from ("Actor-Rank"
            inner join "Rank" using ("id_rank"))
                 inner join "Competition" using ("id_competition")
                 inner join "Employee" on "id_actor" = "id_employee"
        where "id_actor" = NVL(id_actor, "id_actor")
          and "id_gender" = NVL(id_gender, "id_gender")
          and TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")) >= NVL(age_from,
                                                                               TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")))
          and TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")) <= NVL(age_to,
                                                                               TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")))
          and "obtaining_date_actor_rank" >= NVL(date_from, "obtaining_date_actor_rank")
          and "obtaining_date_actor_rank" <= NVL(date_to, "obtaining_date_actor_rank")
          and "id_rank" = NVL(id_rank, "id_rank")
          and "id_competition" = NVL(id_competition, "id_competition");
end;
/

CREATE OR REPLACE procedure actor_rank_list(id_actor IN "Actor-Rank"."id_actor"%TYPE,
                                            list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_rank",
               "name_rank"                 as "Звание",
               "name_competition"          as "Конкурс",
               "obtaining_date_actor_rank" as "Дата получения"
        from ("Actor-Rank" inner join "Rank" using ("id_rank"))
                 inner join "Competition" using ("id_competition")
        where "id_actor" = id_actor;
end;
/

CREATE OR REPLACE procedure actor_rank_insert(id_actor IN "Actor-Rank"."id_actor"%TYPE,
                                              id_rank IN "Actor-Rank"."id_rank"%TYPE,
                                              obtaining_date IN "Actor-Rank"."obtaining_date_actor_rank"%TYPE,
                                              id_competition IN "Actor-Rank"."id_competition"%TYPE)
    is
begin
    INSERT INTO "Actor-Rank" VALUES (id_actor, id_rank, obtaining_date, id_competition);

    COMMIT;
end;
/

CREATE OR REPLACE procedure actor_rank_delete(id_actor IN "Actor-Rank"."id_actor"%TYPE,
                                              id_rank IN "Actor-Rank"."id_rank"%TYPE)
    is
begin
    DELETE
    FROM "Actor-Rank"
    WHERE "id_actor" = id_actor
      and "id_rank" = id_rank;

    COMMIT;
end;
/

CREATE OR REPLACE procedure actor_characteristic_insert(id_actor IN "Actor-Characteristic"."id_actor"%TYPE,
                                                        id_characteristic IN "Actor-Characteristic"."id_characteristic"%TYPE,
                                                        value IN "Actor-Characteristic"."value_actor_characteristic"%TYPE)
    is
begin
    INSERT INTO "Actor-Characteristic" VALUES (id_actor, id_characteristic, value);

    COMMIT;
end;
/

CREATE OR REPLACE procedure actor_characteristic_delete(id_actor IN "Actor-Characteristic"."id_actor"%TYPE,
                                                        id_characteristic IN "Actor-Characteristic"."id_characteristic"%TYPE)
    is
begin
    DELETE
    FROM "Actor-Characteristic"
    WHERE "id_actor" = id_actor
      and "id_characteristic" = id_characteristic;

    COMMIT;
end;
/

CREATE OR REPLACE procedure actor_characteristic_list(id_actor IN "Actor-Characteristic"."id_actor"%TYPE,
                                                      list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_characteristic",
               "type_characteristic"        as "Характеристика",
               "value_actor_characteristic" as "Значение"
        from "Actor-Characteristic"
                 inner join "Characteristic" using ("id_characteristic")
        where "id_actor" = id_actor;
end;
/

CREATE OR REPLACE procedure actor_roles_info(id_actor IN "Employee"."id_employee"%TYPE,
                                             id_gender IN "Employee"."id_gender"%TYPE,
                                             age_from IN INT,
                                             age_to IN INT,
                                             date_from IN "Repertoire"."performance_date_repertoire"%TYPE,
                                             date_to IN "Repertoire"."performance_date_repertoire"%TYPE,
                                             id_genre IN "Genre"."id_genre"%TYPE,
                                             id_age_category IN "Age_category"."id_age_category"%TYPE,
                                             id_director IN "Employee"."id_employee"%TYPE,
                                             actor_roles_cur OUT SYS_REFCURSOR)
    is
begin
    open actor_roles_cur for
        select ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as "Актер",
               "name_role"                                                                     as "Роль",
               "name_show"                                                                     as "Спектакль",
               "name_genre"                                                                    as "Жанр",
               "name_age_category"                                                             as "Возраст",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_director")                                           as "Режиссер"
        from (((("Direction"
            inner join "Employee" on "id_actor" = "id_employee")
            inner join "Role" using ("id_role"))
            inner join "Show" using ("id_show"))
            inner join "Genre" using ("id_genre"))
                 inner join "Age_category" using ("id_age_category")
        where "id_actor" = NVL(id_actor, "id_actor")
          and "id_gender" = NVL(id_gender, "id_gender")
          and TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")) >= NVL(age_from,
                                                                               TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")))
          and TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")) <= NVL(age_to,
                                                                               TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")))
          and "id_genre" = NVL(id_genre, "id_genre")
          and "id_age_category" = NVL(id_age_category, "id_age_category")
          and "id_director" = NVL(id_director, "id_director")
          and "id_show" in (select "id_show"
                            from "Repertoire"
                            where "performance_date_repertoire" >= NVL(date_from, "performance_date_repertoire")
                              and "performance_date_repertoire" <= NVL(date_to, "performance_date_repertoire"));

end;
/

CREATE OR REPLACE procedure get_characteristics_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_characteristic", "type_characteristic"
        from "Characteristic";
end;
/

CREATE OR REPLACE procedure get_director_types_list(list OUT SYS_REFCURSOR, id_director_type OUT INT)
    is
begin
    select "id_job_type"
    into id_director_type
    from "Job_types"
    where "name_job_type" like 'постановщик';

    open list for
        select "id_job_type", "name_job_type"
        from "Job_types"
        where is_sub_job_type(id_director_type, "id_job_type") = 1;
end;
/

CREATE OR REPLACE procedure get_all_types_directors_list(list OUT SYS_REFCURSOR)
    is
    id_director_job_type INT;
begin
    select "id_job_type"
    into id_director_job_type
    from "Job_types"
    where "name_job_type" like 'постановщик';

    open list for
        select "id_employee", ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as name
        from ("Employee"
                 inner join "Job_types" using ("id_job_type"))
        where is_sub_job_type(id_director_job_type, "id_job_type") = 1;
end;
/

CREATE OR REPLACE procedure director_shows(from_date_show IN "Repertoire"."performance_date_repertoire"%TYPE,
                                           to_date_show IN "Repertoire"."performance_date_repertoire"%TYPE,
                                           id_genre IN "Genre"."id_genre"%TYPE,
                                           id_age_category IN "Age_category"."id_age_category"%TYPE,
                                           id_director IN "Author"."id_author"%TYPE,
                                           show_cur OUT SYS_REFCURSOR)
    is
begin
    open show_cur for
        select "id_show",
               "name_show"                                                               as "Название",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_director")                                     as "Режиссер",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_conductor")                                    as "Диpижеp",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_production_designer")                          as "Художник",
               ("name_author" || ' ' || "surname_author" || ' ' || "middle_name_author") as "Автор",
               "name_genre"                                                              as "Жанр",
               "century_show"                                                            as "Век спектакля",
               "premier_date_show"                                                       as "Дата премьеры",
               "name_age_category"                                                       as "Возраст"
        from (("Show" inner join "Author" using ("id_author"))
            inner join "Genre" using ("id_genre"))
                 inner join "Age_category" using ("id_age_category")
        where "id_show" in (select "id_show"
                            from ("Repertoire"
                                     inner join "Show" using ("id_show"))
                            where ("performance_date_repertoire" <= NVL(to_date_show, "performance_date_repertoire")
                                and "performance_date_repertoire" >= NVL(from_date_show, "performance_date_repertoire")
                                and "id_genre" = NVL(id_genre, "id_genre")
                                and "id_age_category" = NVL(id_age_category, "id_age_category")
                                and ("id_director" = id_director or "id_production_designer" = id_director
                                    or "id_conductor" = id_director))
                            group by "id_show");
end;
/

CREATE OR REPLACE procedure get_musicians_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_employee", ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as name
        from ("Employee"
                 inner join "Job_types" using ("id_job_type"))
        where "name_job_type" like 'музыкант';
end;
/

CREATE OR REPLACE procedure get_musical_instruments_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_instrument", "name_instrument"
        from "Musical_instruments";
end;
/

CREATE OR REPLACE procedure musician_info(id_employee IN "Employee"."id_employee"%TYPE,
                                          id_gender IN "Employee"."id_gender"%TYPE,
                                          age_from IN INT,
                                          age_to IN INT,
                                          id_instrument IN "Musical_instruments"."id_instrument"%TYPE,
                                          employee_cur OUT SYS_REFCURSOR)
    is
    id_musician_job_type INT;
begin
    select "id_job_type"
    into id_musician_job_type
    from "Job_types"
    where "name_job_type" like 'музыкант';

    open employee_cur for
        select "id_employee",
               "name_employee"            as "Имя",
               "surname_employee"         as "Фамилия",
               "middle_name_employee"     as "Отчество",
               "name_gender"              as "Гендер",
               "birthday_employee"        as "Дата рождения",
               "hire_date_employee"       as "Дата найма",
               "children_amount_employee" as "Кол-во детей",
               "salary_employee"          as "Зарплата(руб.)",
               "name_education"           as "Образование",
               "name_job_type"            as "Должность",
               "name_instrument"          as "Инструмент"
        from (((("Employee" inner join "Education" using ("id_education"))
            inner join "Gender" using ("id_gender"))
            inner join "Job_types" using ("id_job_type"))
            left join "Musician-Instrument" on "id_musician" = "id_employee")
                 left join "Musical_instruments" using ("id_instrument")
        where (id_employee is not null and "id_employee" = id_employee)
           or (id_employee is null and ("id_gender" = NVL(id_gender, "id_gender")
            and TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")) >= NVL(age_from * 365.242199,
                                                                                 TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")))
            and TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")) <= NVL(age_to * 365.242199,
                                                                                 TRUNC(((SELECT SYSDATE FROM DUAL) - "birthday_employee")))
            and ("id_instrument" = NVL(id_instrument, "id_instrument") or "id_instrument" is null)
            and ("id_job_type" = id_musician_job_type or is_sub_job_type(id_musician_job_type, "id_job_type") = 1)));
end;
/

CREATE OR REPLACE procedure musician_shows(from_date_show IN "Repertoire"."performance_date_repertoire"%TYPE,
                                           to_date_show IN "Repertoire"."performance_date_repertoire"%TYPE,
                                           id_genre IN "Genre"."id_genre"%TYPE,
                                           id_age_category IN "Age_category"."id_age_category"%TYPE,
                                           id_musician IN "Employee"."id_employee"%TYPE,
                                           show_cur OUT SYS_REFCURSOR)
    is
begin
    open show_cur for
        select "id_show",
               "name_show"                                                               as "Название",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_director")                                     as "Режиссер",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_conductor")                                    as "Диpижеp",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_production_designer")                          as "Художник",
               ("name_author" || ' ' || "surname_author" || ' ' || "middle_name_author") as "Автор",
               "name_genre"                                                              as "Жанр",
               "century_show"                                                            as "Век спектакля",
               "premier_date_show"                                                       as "Дата премьеры",
               "name_age_category"                                                       as "Возраст"
        from (("Show" inner join "Author" using ("id_author"))
            inner join "Genre" using ("id_genre"))
                 inner join "Age_category" using ("id_age_category")
        where "id_show" in (select "id_show"
                            from (("Repertoire" inner join "Show" using ("id_show"))
                                     inner join "Musician-Show" using ("id_show"))
                            where ("performance_date_repertoire" <= NVL(to_date_show, "performance_date_repertoire")
                                and "performance_date_repertoire" >= NVL(from_date_show, "performance_date_repertoire")
                                and "id_genre" = NVL(id_genre, "id_genre")
                                and "id_age_category" = NVL(id_age_category, "id_age_category")
                                and ("id_musician" = id_musician))
                            group by "id_show");
end;
/

CREATE OR REPLACE procedure musician_update(id_musician IN "Employee"."id_employee"%TYPE,
                                            id_instrument IN "Musician-Instrument"."id_instrument"%TYPE)
    is
    cnt INT;
begin
    select count(*)
    into cnt
    from "Musician-Instrument"
    where "id_musician" = id_musician;
    if cnt = 0 then
        INSERT INTO "Musician-Instrument" VALUES (id_musician, id_instrument);
    else
        UPDATE "Musician-Instrument" SET "id_instrument" = id_instrument WHERE "id_musician" = id_musician;
    end if;

    COMMIT;
end;
/

CREATE OR REPLACE procedure get_art_employees_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_employee", ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as name
        from ("Employee"
                 inner join "Job_types" using ("id_job_type"))
        where "is_art_job_type" != 0;
end;
/

CREATE OR REPLACE procedure get_job_types_list(list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_job_type", "name_job_type"
        from "Job_types";
end;
/

CREATE OR REPLACE procedure tour_info(id_employee IN "Tour"."id_employee"%TYPE,
                                      id_show IN "Tour"."id_show"%TYPE,
                                      from_date IN "Tour"."from_date_tour"%TYPE,
                                      to_date IN "Tour"."to_date_tour"%TYPE,
                                      is_visiting_tour IN "Tour"."is_visiting_tour"%TYPE,
                                      id_job_type IN "Employee"."id_job_type"%TYPE,
                                      tour_cur OUT SYS_REFCURSOR)
    is
begin
    open tour_cur for
        select "id_employee",
               "id_show",
               ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as "Сотрудник",
               "name_job_type"                                                                 as "Профессия",
               "name_show"                                                                     as "Спектакль",
               "from_date_tour"                                                                as "Дата начала",
               "to_date_tour"                                                                  as "Дата конца",
               ((select 'Выездные' from dual where "is_visiting_tour" != 0)
                   || (select 'Приездные' from dual where "is_visiting_tour" = 0))             as "Тип"
        from ((("Tour" inner join "Employee" using ("id_employee"))
            inner join "Job_types" using ("id_job_type")))
                 inner join "Show" using ("id_show")
        where "id_employee" = NVL(id_employee, "id_employee")
          and "id_show" = NVL(id_show, "id_show")
          and "from_date_tour" >= NVL(from_date, "from_date_tour")
          and "to_date_tour" <= NVL(to_date, "to_date_tour")
          and "is_visiting_tour" = NVL(is_visiting_tour, "is_visiting_tour")
          and ("id_job_type" = NVL(id_job_type, "id_job_type") or is_sub_job_type(id_job_type, "id_job_type") = 1);
end;
/

CREATE OR REPLACE procedure tour_insert(id_employee IN "Tour"."id_employee"%TYPE,
                                        id_show IN "Tour"."id_show"%TYPE,
                                        from_date IN "Tour"."from_date_tour"%TYPE,
                                        to_date IN "Tour"."to_date_tour"%TYPE,
                                        is_visiting_tour IN "Tour"."is_visiting_tour"%TYPE)
    is
begin
    INSERT INTO "Tour" VALUES (id_employee, id_show, from_date, to_date, is_visiting_tour);

    COMMIT;
end;
/

CREATE OR REPLACE procedure tour_delete(id_employee IN "Tour"."id_employee"%TYPE,
                                        id_show IN "Tour"."id_show"%TYPE,
                                        from_date IN "Tour"."from_date_tour"%TYPE,
                                        to_date IN "Tour"."to_date_tour"%TYPE)
    is
begin
    DELETE
    FROM "Tour"
    where "id_employee" = id_employee
      and "id_show" = id_show
      and "from_date_tour" = from_date
      and "to_date_tour" = to_date;

    COMMIT;
end;
/

CREATE OR REPLACE procedure login(login IN "Users"."login"%TYPE,
                                  password IN "Users"."password"%TYPE,
                                  role OUT "User_Role"."name_user_role"%TYPE)
    is
begin
    select "name_user_role"
    into role
    from "Users"
             inner join "User_Role" using ("id_user_role")
    where "login" like login
      and "password" like password;
exception
    when NO_DATA_FOUND then
        raise_application_error(-20044, 'Нет такого логина или пароля!');
end;
/

CREATE OR REPLACE procedure get_ticket(from_date_show IN DATE,
                                       to_date_show IN DATE,
                                       id_show IN "Show"."id_show"%TYPE,
                                       from_century_show IN INT,
                                       to_century_show IN INT,
                                       id_conductor IN "Show"."id_conductor"%TYPE,
                                       id_production_designer IN "Show"."id_production_designer"%TYPE,
                                       id_director IN "Show"."id_director"%TYPE,
                                       id_genre IN "Show"."id_genre"%TYPE,
                                       id_age_category IN "Show"."id_age_category"%TYPE,
                                       id_author IN "Show"."id_author"%TYPE,
                                       id_country IN "Author"."id_country"%TYPE,
                                       tickets_cur OUT SYS_REFCURSOR)
    is
begin
    open tickets_cur for
        select "id_ticket",
               "name_show"                                                               as "Название",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_director")                                     as "Режиссер",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_conductor")                                    as "Диpижеp",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_production_designer")                          as "Художник",
               ("name_author" || ' ' || "surname_author" || ' ' || "middle_name_author") as "Автор",
               "name_genre"                                                              as "Жанр",
               "century_show"                                                            as "Век спектакля",
               "performance_date_repertoire"                                             as "Дата показа",
               "seat_number_ticket"                                                      as "Место",
               "cost_ticket"                                                             as "Цена"
        from ((("Ticket" inner join "Repertoire" using ("id_performance")
            inner join "Show" using ("id_show")) inner join "Author" using ("id_author"))
                 inner join "Genre" using ("id_genre"))
        where ("performance_date_repertoire" <= NVL(to_date_show, "performance_date_repertoire")
            and "performance_date_repertoire" >= NVL(from_date_show, "performance_date_repertoire")
            and "id_show" = NVL(id_show, "id_show")
            and "century_show" <= NVL(to_century_show, "century_show")
            and "century_show" >= NVL(from_century_show, "century_show")
            and "id_conductor" = NVL(id_conductor, "id_conductor")
            and "id_production_designer" = NVL(id_production_designer, "id_production_designer")
            and "id_director" = NVL(id_director, "id_director")
            and "id_genre" = NVL(id_genre, "id_genre")
            and "id_age_category" = NVL(id_age_category, "id_age_category")
            and "id_author" = NVL(id_author, "id_author")
            and "id_country" = NVL(id_country, "id_country")
            and "is_sold" = 0);
end;
/

CREATE OR REPLACE procedure get_subscription(from_century_auth IN INT,
                                             to_century_auth IN INT,
                                             id_genre IN "Show"."id_genre"%TYPE,
                                             id_author IN "Show"."id_author"%TYPE,
                                             id_country IN "Author"."id_country"%TYPE,
                                             subscription_cur OUT SYS_REFCURSOR)
    is
begin
    open subscription_cur for
        select "id_subscription",
               ("name_author" || ' ' || "surname_author" || ' ' || "middle_name_author") as "Автор",
               "name_genre"                                                              as "Жанр"
        from ("Subscription" left join "Author" using ("id_author"))
                 left join "Genre" using ("id_genre")
        where ((("life_century_author" <= NVL(to_century_auth, "life_century_author")
            and "life_century_author" >= NVL(from_century_auth, "life_century_author"))
            or "life_century_author" is null)
            and ("id_genre" = NVL(id_genre, "id_genre") or "id_genre" is null)
            and ("id_author" = NVL(id_author, "id_author") or "id_author" is null)
            and ("id_country" = NVL(id_country, "id_country") or "id_country" is null)
            and "is_sold" = 0);
end;
/

CREATE OR REPLACE procedure get_tickets_in_subscription(id_subscription IN "Subscription"."id_subscription"%TYPE,
                                                        tickets_cur OUT SYS_REFCURSOR)
    is
begin
    open tickets_cur for
        select "id_ticket",
               "name_show"                                                               as "Название",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_director")                                     as "Режиссер",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_conductor")                                    as "Диpижеp",
               (select "name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee"
                from "Employee"
                where "id_employee" = "id_production_designer")                          as "Художник",
               ("name_author" || ' ' || "surname_author" || ' ' || "middle_name_author") as "Автор",
               "name_genre"                                                              as "Жанр",
               "century_show"                                                            as "Век спектакля",
               "performance_date_repertoire"                                             as "Дата показа",
               "seat_number_ticket"                                                      as "Место",
               "cost_ticket"                                                             as "Цена"
        from ((("Ticket" inner join "Repertoire" using ("id_performance")
            inner join "Show" using ("id_show")) inner join "Author" using ("id_author"))
                 inner join "Genre" using ("id_genre"))
        where "id_ticket" in (select "id_ticket"
                              from "Ticket-Subscription"
                              where "id_subscription" = id_subscription);
end;
/

CREATE OR REPLACE procedure get_subscription_by_ticket(id_ticket IN "Ticket"."id_ticket"%TYPE,
                                                       subscription_cur OUT SYS_REFCURSOR)
    is
begin
    open subscription_cur for
        select "id_subscription",
               ("name_author" || ' ' || "surname_author" || ' ' || "middle_name_author") as "Автор",
               "name_genre"                                                              as "Жанр"
        from ("Subscription" left join "Author" using ("id_author"))
                 left join "Genre" using ("id_genre")
        where "id_subscription" in (select "id_subscription"
                                    from "Ticket-Subscription"
                                    where "id_ticket" = id_ticket);
end;
/

CREATE OR REPLACE procedure sell_ticket(id_ticket IN "Ticket"."id_ticket"%TYPE)
    is
    today_date DATE;
    cnt        INT;
begin
    select count(*)
    into cnt
    from "Ticket-Subscription"
    where "id_ticket" = id_ticket;

    if cnt != 0 then
        raise_application_error(-20045, 'Этот билет можно купить только в абонементе!');
    end if;

    select CURRENT_DATE into today_date from dual;

    UPDATE "Ticket" SET "is_sold" = 1, "date_sale" = today_date WHERE "id_ticket" = id_ticket;

    COMMIT;
end;
/

CREATE OR REPLACE procedure sell_subscription(id_subscription IN "Subscription"."id_subscription"%TYPE)
    is
    today_date DATE;
    cursor tickets is
        select "id_ticket"
        from "Ticket-Subscription"
        where "id_subscription" = id_subscription;
begin
    select CURRENT_DATE into today_date from dual;

    for ticket in tickets
        loop
            UPDATE "Ticket" SET "is_sold" = 1, "date_sale" = today_date WHERE "id_ticket" = ticket."id_ticket";
        end loop;

    UPDATE "Subscription" SET "is_sold" = 1 WHERE "id_subscription" = id_subscription;
end;
/

CREATE OR REPLACE procedure get_performances_date_by_show(id_show IN "Repertoire"."id_show"%TYPE,
                                                          list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_performance", "performance_date_repertoire" as "Дата"
        from "Repertoire"
        where "id_show" = id_show;
end;
/

CREATE OR REPLACE procedure ticket_insert(id_performance IN "Ticket"."id_performance"%TYPE,
                                          seat_number IN "Ticket"."seat_number_ticket"%TYPE,
                                          cost IN "Ticket"."cost_ticket"%TYPE)
    is
begin
    INSERT INTO "Ticket" VALUES (0, id_performance, seat_number, cost, 0, null);

    COMMIT;
end;
/

CREATE OR REPLACE procedure ticket_delete(id_ticket "Ticket"."id_ticket"%TYPE)
    is
begin
    DELETE FROM "Ticket" WHERE "id_ticket" = id_ticket;

    COMMIT;
end;
/

CREATE OR REPLACE procedure ticket_to_subscription_insert(id_ticket IN "Ticket-Subscription"."id_ticket"%TYPE,
                                                          id_subscription IN "Ticket-Subscription"."id_subscription"%TYPE)
    is
begin
    INSERT INTO "Ticket-Subscription" VALUES (id_ticket, id_subscription);

    COMMIT;
end;
/

CREATE OR REPLACE procedure subscription_insert(id_genre IN "Subscription"."id_genre"%TYPE,
                                                id_author IN "Subscription"."id_author"%TYPE)
    is
begin
    INSERT INTO "Subscription" VALUES (0, id_genre, id_author, 0);

    COMMIT;
end;
/

CREATE OR REPLACE procedure subscription_delete(id_subscription IN "Subscription"."id_subscription"%TYPE)
    is
begin
    DELETE FROM "Subscription" WHERE "id_subscription" = id_subscription;

    COMMIT;
end;
/

CREATE OR REPLACE procedure tickets_statistic(from_date IN DATE,
                                              to_date IN DATE,
                                              premier IN INT,
                                              id_show IN "Show"."id_show"%TYPE,
                                              from_century_show IN INT,
                                              to_century_show IN INT,
                                              id_conductor IN "Show"."id_conductor"%TYPE,
                                              id_production_designer IN "Show"."id_production_designer"%TYPE,
                                              id_director IN "Show"."id_director"%TYPE,
                                              id_genre IN "Show"."id_age_category"%TYPE,
                                              id_age_category IN "Show"."id_age_category"%TYPE,
                                              id_author IN "Show"."id_author"%TYPE,
                                              id_country IN "Author"."id_country"%TYPE,
                                              ticket_count OUT INT,
                                              money_amount OUT "Ticket"."cost_ticket"%TYPE)
    is
    cursor ticket_cur
        is select "Ticket"."id_ticket", "Ticket"."cost_ticket"
           from ((("Ticket" inner join "Repertoire" using ("id_performance"))
               inner join "Show" using ("id_show"))
                    inner join "Author" using ("id_author"))
           where ("date_sale" <= NVL(to_date, "date_sale")
               and "date_sale" >= NVL(from_date, "date_sale")
               and "id_show" = NVL(id_show, "id_show")
               and "century_show" <= NVL(to_century_show, "century_show")
               and "century_show" >= NVL(from_century_show, "century_show")
               and "id_conductor" = NVL(id_conductor, "id_conductor")
               and "id_production_designer" = NVL(id_production_designer, "id_production_designer")
               and "id_director" = NVL(id_director, "id_director")
               and "id_genre" = NVL(id_genre, "id_genre")
               and "id_age_category" = NVL(id_age_category, "id_age_category")
               and "id_author" = NVL(id_author, "id_author")
               and "id_country" = NVL(id_country, "id_country")
               and ("performance_date_repertoire" = "premier_date_show" or premier = 0)
               and "is_sold" = 1);
begin
    ticket_count := 0;
    money_amount := 0;
    for ticket in ticket_cur
        loop
            ticket_count := ticket_count + 1;
            money_amount := money_amount + ticket."cost_ticket";
        end loop;
end;
/

CREATE OR REPLACE procedure show_delete(id_show IN "Show"."id_show"%TYPE)
    is
begin
    DELETE FROM "Show" WHERE "id_show" = id_show;

    COMMIT;
end;
/

CREATE OR REPLACE procedure show_insert(name IN "Show"."name_show"%TYPE,
                                        century_show IN "Show"."century_show"%TYPE,
                                        id_conductor IN "Show"."id_conductor"%TYPE,
                                        id_production_designer IN "Show"."id_production_designer"%TYPE,
                                        id_director IN "Show"."id_director"%TYPE,
                                        id_genre IN "Show"."id_genre"%TYPE,
                                        id_age_category IN "Show"."id_age_category"%TYPE,
                                        id_author IN "Show"."id_author"%TYPE,
                                        premier_date IN "Show"."premier_date_show"%TYPE)
    is
begin
    INSERT INTO "Show"
    VALUES (0, name, id_director, id_production_designer, id_conductor,
            id_author, id_genre, id_age_category, century_show, premier_date);

    COMMIT;
end;
/

CREATE OR REPLACE procedure show_update(id_show IN "Show"."id_show"%TYPE,
                                        name IN "Show"."name_show"%TYPE,
                                        century_show IN "Show"."century_show"%TYPE,
                                        id_conductor IN "Show"."id_conductor"%TYPE,
                                        id_production_designer IN "Show"."id_production_designer"%TYPE,
                                        id_director IN "Show"."id_director"%TYPE,
                                        id_genre IN "Show"."id_genre"%TYPE,
                                        id_age_category IN "Show"."id_age_category"%TYPE,
                                        id_author IN "Show"."id_author"%TYPE,
                                        premier_date IN "Show"."premier_date_show"%TYPE)
    is
begin
    UPDATE "Show"
    SET "name_show"              = name,
        "id_director"            = id_director,
        "id_production_designer" = id_production_designer,
        "id_conductor"           = id_conductor,
        "id_author"              = id_author,
        "id_genre"               = id_genre,
        "id_age_category"        = id_age_category,
        "century_show"           = century_show,
        "premier_date_show"      = premier_date
    WHERE "id_show" = id_show;

    COMMIT;
end;
/

CREATE OR REPLACE function is_musician_in_show(id_show IN "Show"."id_show"%TYPE,
                                               id_musician IN "Musician-Show"."id_musician"%TYPE)
    return VARCHAR2
    is
    cnt INT;
begin
    select count(*)
    into cnt
    from "Musician-Show"
    where "id_musician" = id_musician
      and "id_show" = id_show;

    if cnt = 0 then
        return 'Нет';
    end if;

    return 'Да';
end;
/

CREATE OR REPLACE procedure get_all_musicians_for_show(id_show IN "Show"."id_show"%TYPE,
                                                       id_instrument IN "Musical_instruments"."id_instrument"%TYPE,
                                                       musicians_cur OUT SYS_REFCURSOR)
    is
begin
    open musicians_cur for
        select "id_employee",
               ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as "Музыкант",
               is_musician_in_show(id_show, "id_employee")                                     as "В этом спектакле",
               "name_instrument"                                                               as "Инструмент"
        from "Employee"
                 inner join "Musician-Instrument" on "Employee"."id_employee" = "Musician-Instrument"."id_musician"
                 inner join "Musical_instruments" using ("id_instrument")
        where "id_instrument" = NVL(id_instrument, "id_instrument");
end;
/

CREATE OR REPLACE procedure set_musician_for_show(id_show IN "Show"."id_show"%TYPE,
                                                  id_employee IN "Musician-Show"."id_musician"%TYPE)
    is
begin
    INSERT INTO "Musician-Show" VALUES (id_employee, id_show);

    COMMIT;
end;
/

CREATE OR REPLACE procedure delete_musician_from_show(id_show IN "Show"."id_show"%TYPE,
                                                      id_employee IN "Musician-Show"."id_musician"%TYPE)
    is
begin
    DELETE FROM "Musician-Show" WHERE "id_musician" = id_employee and "id_show" = id_show;

    COMMIT;
end;
/

CREATE OR REPLACE procedure get_roles_for_show(id_show IN "Show"."id_show"%TYPE,
                                               list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_role", "name_role", "is_main_role"
        from "Role"
        where "id_show" = id_show;
end;
/

CREATE OR REPLACE procedure get_role_characteristics(id_role IN "Role-Characteristic"."id_role"%TYPE,
                                                     characteristics_cur OUT SYS_REFCURSOR)
    is
begin
    open characteristics_cur for
        select "id_characteristic", "type_characteristic" as "Тип", "value_role_characteristic" as "Значение"
        from "Role-Characteristic"
                 inner join "Characteristic" using ("id_characteristic")
        where "id_role" = id_role;
end;
/

CREATE OR REPLACE procedure role_info(id_role IN "Role-Characteristic"."id_role"%TYPE,
                                      is_main_role OUT "Role"."is_main_role"%TYPE)
    is
begin
    select "is_main_role"
    into is_main_role
    from "Role"
    where "id_role" = id_role;
end;
/

CREATE OR REPLACE procedure role_delete(id_role IN "Role"."id_role"%TYPE)
    is
begin
    DELETE FROM "Role" WHERE "id_role" = id_role;

    COMMIT;
end;
/

CREATE OR REPLACE procedure role_insert(name IN "Role"."name_role"%TYPE,
                                        id_show IN "Role"."id_show"%TYPE,
                                        is_main_role IN "Role"."is_main_role"%TYPE)
    is
begin
    INSERT INTO "Role" VALUES (0, id_show, name, is_main_role);

    COMMIT;
end;
/

CREATE OR REPLACE procedure role_update(id_role IN "Role"."id_role"%TYPE,
                                        name IN "Role"."name_role"%TYPE,
                                        is_main_role IN "Role"."is_main_role"%TYPE)
    is
begin
    UPDATE "Role"
    SET "name_role"    = name,
        "is_main_role" = is_main_role
    WHERE "id_role" = id_role;

    COMMIT;
end;
/

CREATE OR REPLACE procedure role_characteristic_insert(id_role IN "Role-Characteristic"."id_role"%TYPE,
                                                       id_characteristics IN "Role-Characteristic"."id_characteristic"%TYPE,
                                                       value IN "Role-Characteristic"."value_role_characteristic"%TYPE)
    is
begin
    INSERT INTO "Role-Characteristic" VALUES (id_characteristics, id_role, value);

    COMMIT;
end;
/

CREATE OR REPLACE procedure role_characteristic_delete(id_role IN "Role-Characteristic"."id_role"%TYPE,
                                                       id_characteristics IN "Role-Characteristic"."id_characteristic"%TYPE)
    is
begin
    DELETE FROM "Role-Characteristic" WHERE "id_characteristic" = id_characteristics and "id_role" = id_role;

    COMMIT;
end;
/

CREATE OR REPLACE function is_actor_fit_into_the_role(id_role IN "Role-Characteristic"."id_role"%TYPE,
                                                      id_actor IN "Direction"."id_actor"%TYPE)
    return int
    is
    cursor role_characteristic is
        select "id_characteristic"
        from "Role-Characteristic"
        where "id_role" = id_role;
    cursor actor_characteristic is
        select "id_characteristic"
        from "Actor-Characteristic"
        where "id_actor" = id_actor;
    found boolean;
begin
    for role_ch in role_characteristic
        loop
            found := false;
            for actor_ch in actor_characteristic
                loop
                    if role_ch."id_characteristic" = actor_ch."id_characteristic" then
                        found := true;
                        exit;
                    end if;
                end loop;
            if not found then
                return 0;
            end if;
        end loop;
    return 1;
end;
/

CREATE OR REPLACE procedure get_actors_for_role(id_role IN "Role-Characteristic"."id_role"%TYPE,
                                                list OUT SYS_REFCURSOR)
    is
begin
    open list for
        select "id_employee",
               ("name_employee" || ' ' || "surname_employee" || ' ' || "middle_name_employee") as "Актер"
        from "Employee"
                 inner join "Job_types" using ("id_job_type")
        where "name_job_type" like 'актер'
          and is_actor_fit_into_the_role(id_role, "id_employee") = 1;
end;
/

CREATE OR REPLACE procedure set_actor_to_role(id_role IN "Role-Characteristic"."id_role"%TYPE,
                                              id_actor IN "Direction"."id_actor"%TYPE,
                                              is_understudy IN "Direction"."is_understudy_direction"%TYPE)
    is
begin
    INSERT INTO "Direction" VALUES (id_actor, id_role, is_understudy);

    COMMIT;
end;
/

CREATE OR REPLACE procedure delete_actor_from_role(id_role IN "Role-Characteristic"."id_role"%TYPE,
                                                   id_actor IN "Direction"."id_actor"%TYPE)
    is
begin
    DELETE FROM "Direction" WHERE "id_actor" = id_actor and "id_role" = id_role;

    COMMIT;
end;
/

CREATE OR REPLACE procedure performance_insert(id_show IN "Show"."id_show"%TYPE,
                                               date_performance IN "Repertoire"."performance_date_repertoire"%TYPE)
    is
begin
    INSERT INTO "Repertoire" VALUES (0, id_show, date_performance);

    COMMIT;
end;
/

CREATE OR REPLACE procedure performance_delete(id_performance IN "Repertoire"."id_performance"%TYPE)
    is
begin
    DELETE FROM "Repertoire" WHERE "id_performance" = id_performance;

    COMMIT;
end;
/


