/* =========================================================================
   app.js - YPA Academy single-page behaviour (jQuery 3 + Bootstrap 5)

   How it works:
   1. The navbar links point at hashes: #home, #branches, #achievers,
      #events, #professors, #students.
   2. Clicking one changes the hash (the page does NOT reload) and fires
      the browser's "hashchange" event.
   3. router() looks the hash up in ROUTES, calls the matching JSON endpoint
      (index.cfm?action=api.<name>) with $.getJSON, and draws the result
      into <main id="app">.

   Safety: everything that comes from the database is inserted with
   jQuery's .text() (or .attr() for attributes), never as raw HTML, so a
   name like "<script>" is shown as plain text and cannot run.
   ========================================================================= */
(function ($) {
    'use strict';

    // ---- Settings --------------------------------------------------------

    // Set on <body data-api-url="..."> by layouts/default.cfm,
    // e.g. "/index.cfm?action=api." -> add "professors" to get the full URL.
    var API_URL = $('body').data('api-url');

    // The site's folder (usually "/"), used to turn stored image paths such
    // as "assets/uploads/professors/abc.jpg" into working URLs.
    var BASE_PATH = $('body').data('base-path') || '/';

    // Admin mode: set by the server only when the admin is logged in.
    // It only shows extra links; every admin page checks the login itself.
    var IS_ADMIN = $('body').attr('data-is-admin') === 'true';
    var ADMIN_URL = $('body').data('admin-url') || '';   // e.g. "/index.cfm?action=admin."

    // The section currently shown ("home", "professors", ...). Sent to the
    // admin forms as returnTo, so saving brings the admin back here.
    var currentRoute = 'home';

    // Professor accent colours: green, blue, red, then slate for the rest.
    var ACCENTS = ['#1E7B3C', '#0B6FA8', '#C0392B'];
    var DEFAULT_ACCENT = '#34495E';

    var ERROR_MESSAGE = "Sorry, we couldn't load this right now. Please try again in a moment.";
    var MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    var $app = $('#app');

    // The home markup the server sent on first load. We keep a copy so we
    // can put it back when the visitor returns to #home.
    var homeHtml = $app.html();

    // Professors from the last load, by id, so the modal can show details
    // without asking the server again.
    var professorsById = {};

    // ---- Routes ----------------------------------------------------------
    // One entry per hash. "endpoint" is the api.* action to call, "draw"
    // turns the rows into HTML, "empty" is shown when there are no rows.
    // "singular" is used for the admin "Add ..." button and pencil labels.
    var ROUTES = {
        home: {
            title: 'Home'
        },
        professors: {
            title: 'YPA Professors',
            endpoint: 'professors',
            singular: 'professor',
            draw: drawProfessors,
            empty: 'Our professor profiles are coming soon.'
        },
        branches: {
            title: 'YPA Branches',
            endpoint: 'branches',
            singular: 'branch',
            draw: drawBranches,
            empty: 'No branches have been added yet.'
        },
        achievers: {
            title: 'YPA Achievers',
            endpoint: 'achievers',
            singular: 'achiever',
            draw: drawAchievers,
            empty: 'Our achievers list is coming soon.'
        },
        events: {
            title: 'YPA Events',
            endpoint: 'events',
            singular: 'event',
            draw: drawEvents,
            empty: 'There are no upcoming events right now. Please check back soon.'
        },
        students: {
            title: 'YPA Students',
            endpoint: 'students',
            singular: 'student',
            draw: drawStudents,
            empty: 'No students have been added yet.'
        }
    };

    // ---- Router ----------------------------------------------------------

    /**
     * Shows the section named in the URL hash.
     * isFirstLoad is true only when the page first opens.
     */
    function router(isFirstLoad) {
        var name = window.location.hash.replace(/^#/, '').toLowerCase();

        if (name === '') {
            name = 'home';
        } else if (!ROUTES[name]) {
            // An unknown hash, e.g. "#app" from the "Skip to main content"
            // link. After the first load we leave the page as it is.
            if (!isFirstLoad) {
                return;
            }
            name = 'home';
        }

        var route = ROUTES[name];
        currentRoute = name;
        document.title = route.title + ' | YPA Academy';
        setActiveLink(name);
        closeMobileMenu();

        if (name === 'home') {
            showHome();
        } else {
            showSection(route, name);
        }

        // After a click (not on first load): go to the top and move keyboard
        // focus to the new heading so screen readers announce the change.
        if (!isFirstLoad) {
            window.scrollTo(0, 0);
            $app.find('h1').first().attr('tabindex', '-1').trigger('focus');
        }
    }

    /** Puts the hero + professors grid back and loads the professors. */
    function showHome() {
        $app.html(homeHtml);
        loadInto($app.find('.js-professor-grid'), ROUTES.professors, 'h3');
    }

    /** Builds an empty section with a heading, then loads its data into it. */
    function showSection(route, name) {
        var $content = $('<div aria-live="polite"></div>');
        var $section = $('<section class="page-section"></section>')
            .attr('aria-labelledby', name + 'Title')
            .append(
                $('<div class="container"></div>').append(
                    $('<h1 class="section-title"></h1>').attr('id', name + 'Title').text(route.title),
                    $content
                )
            );

        $app.empty().append($section);
        loadInto($content, route, 'h2');
    }

    /**
     * Calls the route's API endpoint and draws the result into $target.
     * Shows a spinner while waiting, and a message if the list is empty or
     * the request fails. itemHeading is the heading tag for each item
     * (h2 or h3) so heading levels stay in order.
     */
    function loadInto($target, route, itemHeading) {
        $target.empty().append(spinner());

        $.getJSON(API_URL + route.endpoint)
            .done(function (response) {
                if (!response || response.ok === false) {
                    showError($target, route, itemHeading, response && response.message);
                    return;
                }

                var items = lowerCaseKeys(response.data || []);

                // Admin only: an "Add ..." button above the list (also when
                // the list is empty, so the first item can be added).
                $target.empty().append(addButton(route));

                if (items.length === 0) {
                    $target.append(message(route.empty));
                    return;
                }

                $target.append(route.draw(items, itemHeading));
            })
            .fail(function (xhr) {
                var serverMessage = xhr.responseJSON && xhr.responseJSON.message;
                showError($target, route, itemHeading, serverMessage);
            });
    }

    /** Error message with a "Try again" button that repeats the request. */
    function showError($target, route, itemHeading, text) {
        var $retry = $('<button type="button" class="btn btn-outline-dark mt-3">Try again</button>')
            .on('click', function () {
                loadInto($target, route, itemHeading);
            });

        $target.empty().append(
            $('<div class="status-message status-message--error" role="alert"></div>')
                .append($('<p class="mb-0"></p>').text(text || ERROR_MESSAGE), $retry)
        );
    }

    // ---- Drawing each section --------------------------------------------

    /** Professor cards: 3 per row on desktop, 2 on tablet, 1 on phones. */
    function drawProfessors(items, headingTag) {
        var $row = gridRow();
        professorsById = {};

        $.each(items, function (index, prof) {
            var accent = accentFor(prof, index);
            professorsById[prof.id] = $.extend({}, prof, { accent: accent });

            var $card = $('<article class="prof-card"></article>')
                .css('--accent', accent)    // CSS uses var(--accent) for the colours
                .append(
                    editPencil('professors', prof.id, prof.name),
                    $('<p class="prof-card__subject"></p>').text(prof.subject),
                    photo(prof.photo_url, prof.name, ''),
                    $('<' + headingTag + ' class="prof-card__name"></' + headingTag + '>').text(prof.name),
                    $('<p class="prof-card__meta"></p>').text(qualificationLine(prof)),
                    $('<p class="prof-card__teach"></p>').text(firstSentence(prof.bio)),
                    $('<button type="button" class="btn btn-accent js-view-profile">View profile</button>')
                        .attr('data-id', prof.id)
                        .attr('aria-label', 'View profile of ' + prof.name)
                );

            $row.append($('<div class="col"></div>').append($card));
        });

        return $row;
    }

    /** Branch cards with address and a tap-to-call phone link. */
    function drawBranches(items, headingTag) {
        var $row = gridRow();

        $.each(items, function (i, branch) {
            var $card = $('<article class="info-card"></article>').append(
                editPencil('branches', branch.id, branch.name),
                coverImage(branch.image_url, branch.name),
                $('<' + headingTag + ' class="info-card__title"></' + headingTag + '>').text(branch.name),
                $('<p class="info-card__text"></p>').text(branch.address || '')
            );

            if (branch.phone) {
                $card.append(
                    $('<p class="info-card__text mb-0"></p>').append(
                        $('<a></a>')
                            .attr('href', 'tel:' + String(branch.phone).replace(/[^0-9+]/g, ''))
                            .text(branch.phone)
                    )
                );
            }

            $row.append($('<div class="col"></div>').append($card));
        });

        return $row;
    }

    /** Achiever cards: photo, name, exam, rank/post and year. */
    function drawAchievers(items, headingTag) {
        var $row = gridRow();

        $.each(items, function (i, person) {
            var $card = $('<article class="info-card"></article>').append(
                editPencil('achievers', person.id, person.name),
                photo(person.photo_url, person.name, 'photo--small'),
                $('<' + headingTag + ' class="info-card__title"></' + headingTag + '>').text(person.name),
                $('<p class="info-card__text"></p>').text((person.exam || '') + (person.year ? ' · ' + person.year : '')),
                $('<span class="info-card__badge"></span>').text(person.rank_or_post)
            );

            $row.append($('<div class="col"></div>').append($card));
        });

        return $row;
    }

    /** Events as a list with a date tile on the left. */
    function drawEvents(items, headingTag) {
        var $list = $('<ul class="event-list"></ul>');

        $.each(items, function (i, event) {
            var date = splitDate(event.event_date);

            var $tile = $('<time class="event-date"></time>')
                .attr('datetime', event.event_date)
                .append(
                    $('<span class="event-date__day"></span>').text(date.day),
                    $('<span class="event-date__month"></span>').text(date.month + ' ' + date.year)
                );

            var $body = $('<div class="event-item__body"></div>').append(
                $('<' + headingTag + ' class="event-item__title"></' + headingTag + '>').text(event.title),
                $('<p class="event-item__meta"></p>').text(event.branch_name ? event.branch_name : 'All branches'),
                $('<p class="event-item__text"></p>').text(event.description || '')
            );

            var $item = $('<li class="event-item"></li>').append(
                editPencil('events', event.id, event.title),
                $tile,
                $body
            );

            // Optional event image on the right
            if (isSafeUrl(event.image_url)) {
                $item.append(
                    $('<img class="event-item__image" loading="lazy">')
                        .attr('src', assetUrl(event.image_url))
                        .attr('alt', event.title)
                        .on('error', function () { $(this).remove(); })
                );
            }

            $list.append($item);
        });

        return $list;
    }

    /** Students in a simple table (scrolls sideways on narrow phones). */
    function drawStudents(items) {
        var $tbody = $('<tbody></tbody>');

        $.each(items, function (i, student) {
            // Name cell: small round photo (if any) + the name
            var $name = $('<td></td>');
            if (isSafeUrl(student.photo_url)) {
                $name.append(
                    $('<img class="student-avatar" loading="lazy" alt="">')
                        .attr('src', assetUrl(student.photo_url))
                        .on('error', function () { $(this).remove(); })
                );
            }
            $name.append(document.createTextNode(student.name));

            var $row = $('<tr></tr>').append(
                $name,
                $('<td></td>').text(student.batch || ''),
                $('<td></td>').text(student.branch_name || '')
            );
            if (IS_ADMIN) {
                $row.append($('<td class="text-end"></td>').append(editPencil('students', student.id, student.name, true)));
            }
            $tbody.append($row);
        });

        var $headRow = $('<tr><th scope="col">Name</th><th scope="col">Batch</th><th scope="col">Branch</th></tr>');
        if (IS_ADMIN) {
            $headRow.append('<th scope="col"><span class="visually-hidden">Edit</span></th>');
        }

        var $table = $('<table class="table table-striped align-middle mb-0"></table>').append(
            $('<caption class="visually-hidden">Current YPA students, their batch and branch</caption>'),
            $('<thead></thead>').append($headRow),
            $tbody
        );

        return $('<div class="table-responsive student-table"></div>').append($table);
    }

    // ---- Professor modal -------------------------------------------------

    /** Fills the Bootstrap modal with one professor's details and opens it. */
    function openProfessorModal(id) {
        var prof = professorsById[id];
        if (!prof) {
            return;
        }

        $('#professorModalTitle').text(prof.name);

        var $profile = $('<div class="modal-profile"></div>')
            .css('--accent', prof.accent)
            .append(
                photo(prof.photo_url, prof.name, ''),
                $('<p class="modal-profile__subject"></p>').text(prof.subject),
                $('<p class="modal-profile__meta"></p>').text(qualificationLine(prof)),
                $('<p class="modal-profile__bio"></p>').text(prof.bio || 'More details coming soon.')
            );

        $('#professorModalBody').empty().append($profile);

        // Bootstrap returns keyboard focus to the "View profile" button on close.
        bootstrap.Modal.getOrCreateInstance(document.getElementById('professorModal')).show();
    }

    // ---- Small helpers ---------------------------------------------------

    /** Bootstrap row: 1 column on phones, 2 on tablets, 3 on desktops. */
    function gridRow() {
        return $('<div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 card-grid"></div>');
    }

    /** Loading spinner (the hidden text is read out by screen readers). */
    function spinner() {
        return $('<div class="loading"><div class="spinner-border" role="status"><span class="visually-hidden">Loading…</span></div></div>');
    }

    /** A plain centred message, e.g. for an empty list. */
    function message(text) {
        return $('<p class="status-message"></p>').text(text);
    }

    /**
     * A round photo, or a dashed "Photo" placeholder when there is no photo
     * (or the image fails to load). extraClass is e.g. "photo--small".
     */
    function photo(url, name, extraClass) {
        var placeholder = function () {
            return $('<div class="photo photo--placeholder" role="img"></div>')
                .addClass(extraClass)
                .attr('aria-label', 'No photo available for ' + name)
                .append('<span aria-hidden="true">Photo</span>');
        };

        if (!isSafeUrl(url)) {
            return placeholder();
        }

        return $('<img class="photo" loading="lazy">')
            .addClass(extraClass)
            .attr('src', assetUrl(url))
            .attr('alt', 'Photo of ' + name)
            .on('error', function () {
                $(this).replaceWith(placeholder());
            });
    }

    /** A wide image across the top of a card (branches). Nothing if no image. */
    function coverImage(url, name) {
        if (!isSafeUrl(url)) {
            return null;
        }
        return $('<img class="info-card__image" loading="lazy">')
            .attr('src', assetUrl(url))
            .attr('alt', name)
            .on('error', function () { $(this).remove(); });
    }

    /**
     * Stored image paths are relative to the site ("assets/uploads/x.jpg").
     * Add the site folder in front so they work from any page address.
     * Full URLs ("https://...") and paths starting with "/" are left alone.
     */
    function assetUrl(url) {
        url = String(url).trim();
        if (/^https?:\/\//i.test(url) || url.charAt(0) === '/') {
            return url;
        }
        return BASE_PATH + url;
    }

    // ---- Admin helpers (only produce something when logged in) ------------

    /** Link to the admin add/edit form; returnTo brings the admin back here. */
    function adminFormUrl(type, id) {
        return ADMIN_URL + 'edit&type=' + encodeURIComponent(type) +
            (id ? '&id=' + encodeURIComponent(id) : '') +
            '&returnTo=' + encodeURIComponent(currentRoute);
    }

    /**
     * Pencil icon linking to the edit form. "inline" = sits in normal flow
     * (table cell) instead of the top-right corner of a card.
     */
    function editPencil(type, id, name, inline) {
        if (!IS_ADMIN) {
            return null;
        }
        return $('<a class="edit-pencil"></a>')
            .toggleClass('edit-pencil--inline', !!inline)
            .attr('href', adminFormUrl(type, id))
            .attr('aria-label', 'Edit ' + name)
            .append(pencilIcon());
    }

    /** "Add professor" (etc.) button shown above a list. */
    function addButton(route) {
        if (!IS_ADMIN || !route.singular) {
            return null;
        }
        return $('<div class="admin-toolbar"></div>').append(
            $('<a class="btn btn-dark"></a>')
                .attr('href', adminFormUrl(route.endpoint))
                .text('+ Add ' + route.singular)
        );
    }

    /** The pencil SVG (decorative: the link carries the label). */
    function pencilIcon() {
        return '<svg width="16" height="16" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
            '<path d="M4 20h4L19 9l-4-4L4 16v4zM14 6l4 4" fill="none" stroke="currentColor" ' +
            'stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    }

    /** Only allow http(s) links or paths on this site (blocks "javascript:" etc.). */
    function isSafeUrl(url) {
        if (!url) {
            return false;
        }
        url = String(url).trim();
        return /^https?:\/\//i.test(url) || !/^[a-z][a-z0-9+.-]*:/i.test(url);
    }

    /** Use the professor's colour from the database if valid, else rotate. */
    function accentFor(prof, index) {
        if (/^#[0-9a-f]{6}$/i.test(prof.accent_color || '')) {
            return prof.accent_color;
        }
        return ACCENTS[index] || DEFAULT_ACCENT;
    }

    /** "M.Sc. Mathematics · 11 years of experience" */
    function qualificationLine(prof) {
        var years = Number(prof.experience_years) || 0;
        var parts = [];
        if (prof.qualification) {
            parts.push(prof.qualification);
        }
        if (years > 0) {
            parts.push(years + (years === 1 ? ' year' : ' years') + ' of experience');
        }
        return parts.join(' · ');
    }

    /** The first sentence of a bio, used as the short "what they teach" line. */
    function firstSentence(text) {
        if (!text) {
            return '';
        }
        var match = String(text).match(/^.*?[.!?](\s|$)/);
        return (match ? match[0] : String(text)).trim();
    }

    /** "2026-10-18" -> { day: "18", month: "Oct", year: "2026" } (no time-zone surprises). */
    function splitDate(isoDate) {
        var parts = String(isoDate || '').split('-');
        return {
            year: parts[0] || '',
            month: MONTHS[Number(parts[1]) - 1] || '',
            day: parts[2] ? String(Number(parts[2])) : ''
        };
    }

    /**
     * Lucee may send column names in a different case (e.g. "NAME").
     * This makes every key lower case so the code above can use row.name.
     */
    function lowerCaseKeys(rows) {
        return $.map(rows, function (row) {
            var copy = {};
            $.each(row, function (key, value) {
                copy[String(key).toLowerCase()] = value;
            });
            return copy;
        });
    }

    /** Marks the current section's navbar link as active. */
    function setActiveLink(name) {
        $('.site-nav .nav-link').removeClass('active').removeAttr('aria-current');
        $('.site-nav .nav-link[data-route="' + name + '"]').addClass('active').attr('aria-current', 'page');
    }

    /** On phones, close the hamburger menu after a link is chosen. */
    function closeMobileMenu() {
        var menu = document.getElementById('mainNav');
        if (menu && menu.classList.contains('show')) {
            bootstrap.Collapse.getOrCreateInstance(menu, { toggle: false }).hide();
        }
    }

    // ---- Event listeners -------------------------------------------------

    // The hash changed (navbar click, back/forward button): show that section.
    $(window).on('hashchange', function () {
        router(false);
    });

    // "View profile" buttons are created later, so listen on #app instead
    // ("event delegation") and check which button was clicked.
    $app.on('click', '.js-view-profile', function () {
        openProfessorModal($(this).attr('data-id'));
    });

    // Hero down-arrow: smooth-scroll to the professors heading.
    $app.on('click', '.js-scroll-to-professors', function () {
        var target = document.getElementById('professors-section');
        if (!target) {
            return;
        }
        var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        target.scrollIntoView({ behavior: reduceMotion ? 'auto' : 'smooth' });
        // Move keyboard focus too, without a second jump.
        document.getElementById('professorsTitle').focus({ preventScroll: true });
    });

    // ---- Start -----------------------------------------------------------
    $(function () {
        router(true);
    });

})(jQuery);
