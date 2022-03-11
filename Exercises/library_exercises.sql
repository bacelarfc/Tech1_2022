-- 1. Show the members under the name "Jens S." who were born before 1970 that became members of the library in 2013.
SELECT *
FROM library.tmember
WHERE cName LIKE 'Jens S.' AND dBirth < '1970.01.01' AND dNewMember LIKE '2013%';

-- 2. Show those books that have not been published by the publishing companies with ID 15 and 32, except if they were published before 2000.
SELECT * FROM tbook WHERE NOT (nPublishingCompanyID = 15 AND nPublishingCompanyID = 32) OR nPublishingYear < '2000-01-01';

-- 3. Show the name and surname of the members who have a phone number, but no address.
SELECT cName, cSurname FROM tmember WHERE cPhoneNo IS NOT NULL AND cAddress IS NULL;

-- 4. Show the authors with surname "Byatt" whose name starts by an "A" (uppercase) and contains an "S" (uppercase).
SELECT * FROM tauthor WHERE cSurname = 'Byatt' AND cName LIKE 'A%' AND cName LIKE '%S%';

-- 5. Show the number of books published in 2007 by the publishing company with ID 32.
SELECT COUNT(*) AS Books_Published_in_2007 FROM tbook WHERE nPublishingYear = 2007 AND nPublishingCompanyID = 32;

-- 6. For each day of the year 2014, show the number of books loaned by the member with CPR "0305393207";
SELECT COUNT(*) AS Loaned_Books FROM tloan WHERE cCPR = '0305393207' AND dLoan LIKE '2014%';

-- 7. Modify the previous clause so that only those days where the member was loaned more than one book appear.
SELECT dLoan FROM tloan WHERE cCPR = '0305393207' AND dLoan LIKE '2014%' GROUP BY dLoan HAVING count(*) > 1;

-- 8. Show all library members from the newest to the oldest. Those who became members on the same day will be sorted alphabetically (by surname and name) within that day.
SELECT * FROM tmember ORDER BY dNewMember DESC, cSurname,cName;

-- 9. Show the title of all books published by the publishing company with ID 32 along with their theme or themes.
SELECT cTitle FROM tbook, tbooktheme, ttheme WHERE nPublishingCompanyID = 32
AND tbook.nBookID = tbooktheme.nBookID AND tbooktheme.nThemeID = ttheme.nThemeID;

SELECT cTitle
FROM tbook
LEFT JOIN tbooktheme
ON tbook.nBookID = tbooktheme.nBookID
LEFT JOIN ttheme
ON tbooktheme.nThemeID = ttheme.nThemeID WHERE nPublishingCompanyID = 32;

-- 10. Show the name and surname of every author along with the number of books authored by them, but only for authors who have registered books on the database.
SELECT cName, cSurname, COUNT(tbook.cTitle) FROM tauthor, tbook, tauthorship WHERE tauthor.nAuthorID = tauthorship.nAuthorID
AND tauthorship.nBookID = tbook.nBookID AND cTitle IS NOT NULL GROUP BY cNAme, cSurname;

-- 11. Show the name and surname of all the authors with published books along with the lowest publishing year for their books.
SELECT cName, cSurname, MIN(nPublishingYear) AS MinimumYear FROM tauthor, tauthorship, tbook
WHERE tauthor.nAuthorID = tauthorship.nAuthorID AND tauthorship.nBookID = tbook.nBookID AND cTitle IS NOT  NULL group by cName, cSurname;

-- 12. For each signature and loan date, show the title of the corresponding books and the name and surname of the member who had them loaned.
SELECT cName, cSurname, cTitle
FROM tmember
LEFT JOIN tloan
on tmember.cCPR = tloan.cCPR
LEFT JOIN tbookcopy
ON tbookcopy.cSignature = tloan.cSignature
LEFT JOIN tbook
ON tbook.nBookID = tbookcopy.nBookID;

-- 13. Repeat exercises 9 to 12 using the modern JOIN notation.

       -- Check answers at the respective numbers

-- 14. Show all theme names along with the titles of their associated books. All themes must appear (even if there are no books for some particular themes). Sort by theme name.
SELECT ttheme.cName AS Theme, cTitle
FROM ttheme
LEFT JOIN tbooktheme
ON ttheme.nThemeID = tbooktheme.nThemeID
LEFT JOIN tbook
ON tbook.nBookID = tbooktheme.nBookID
ORDER BY cName;

-- 15. Show the name and surname of all members who joined the library in 2013 along with the title of the books they took on loan during that same year. All members must be shown, even if they did not take any book on loan during 2013. Sort by member surname and name.
SELECT cName, cSurname, if(dLoan LIKE '2013%', tbook.cTitle, '') AS Rented_Books_In_2013
FROM tmember
RIGHT JOIN tloan
ON tmember.cCPR = tloan.cCPR
LEFT JOIN tbookcopy
ON tbookcopy.cSignature = tloan.cSignature
LEFT JOIN tbook
ON tbook.nBookID = tbookcopy.nBookID
WHERE dNewMember LIKE '2013%'
ORDER BY cName, cSurname;

-- 16. Show the name and surname of all authors along with their nationality or nationalities and the titles of their books. Every author must be shown, even though s/he has no registered books. Sort by author name and surname.
SELECT tauthor.cName, tauthor.cSurname, tcountry.cName, tbook.cTitle
FROM tauthor
RIGHT JOIN tnationality
ON tauthor.nAuthorID = tnationality.nAuthorID
LEFT JOIN tcountry
ON tcountry.nCountryID = tnationality.nCountryID
RIGHT JOIN tauthorship
ON tauthor.nAuthorID = tauthorship.nAuthorID
RIGHT JOIN tbook
ON tbook.nBookID = tauthorship.nBookID
ORDER BY tauthor.cName, cSurname;

-- 17.  Show the title of those books which have had different editions published in both 1970 and 1989.
SELECT cTitle FROM tbook WHERE nPublishingYear = 1970 OR nPublishingYear = 1989 GROUP BY nPublishingYear HAVING COUNT(*) > 1;


-- 18. Show the surname and name of all members who joined the library in December 2013 followed by the surname and name of those authors whose name is “William”.
SELECT tmember.cSurname, tmember.cName, tauthor.cSurname, tauthor.cName FROM tmember, tauthor WHERE dNewMember LIKE '2013-12%' AND tauthor.cName = 'William';

-- 19. Show the name and surname of the first chronological member of the library using subqueries.
 -- Chronological = First in the time
SELECT cName, cSurname, dNewMember FROM tmember ORDER BY dNewMember ASC LIMIT 1;

SELECT  cName, cSurname
FROM tmember
WHERE dNewMember IN
(SELECT dNewMember
FROM tmember) ORDER BY dNewMember ASC LIMIT 1;



-- 20. For each publishing year, show the number of book titles published by publishing companies from countries that constitute = have the nationality for at least three authors.

 -- Use subqueries.

SELECT (SELECT COUNT(cTitle) FROM tbook AS numberoftitles)
FROM tbook
LEFT JOIN tpublishingcompany
ON tbook.nPublishingCompanyID = tpublishingcompany.nPublishingCompanyID
LEFT JOIN tcountry
ON tcountry.nCountryID = tpublishingcompany.nCountryID
LEFT JOIN tnationality
 ON tnationality.nCountryID = tcountry.nCountryID;

SELECT nPublishingYear, COUNT(*) AS 'Books Published', cName
FROM tbook,
(SELECT cName
FROM tcountry
LEFT JOIN tnationality t on tcountry.nCountryID = t.nCountryID
GROUP BY cName
HAVING COUNT(*) >= 3) name
LEFT JOIN tauthorship
ON tauthorship.nBookID
GROUP BY nPublishingYear, cName
ORDER BY nPublishingYear;


-- 21. Show the name and country of all publishing companies with the headings "Name" and "Country".
SELECT tpublishingcompany.cName AS Name, tcountry.cName AS Country
FROM tpublishingcompany
LEFT JOIN tcountry
ON tpublishingcompany.nCountryID = tcountry.nCountryID;

-- 22. Show the titles of the books published between 1926 and 1978 that were not published by the publishing company with ID 32.
SELECT tbook.cTitle, nPublishingYear
FROM tbook
WHERE nPublishingYear IN
(SELECT nPublishingYear
FROM tbook WHERE nPublishingYear BETWEEN '1926%' AND '1978%' AND NOT nPublishingCompanyID = '32');


-- 23. Show the name and surname of the members who joined the library after 2016 and have no address.
SELECT tmember.cName, tmember.cSurname, tmember.cAddress
FROM tmember WHERE dNewMember IN (SELECT dNewMember FROM tmember WHERE dNewMember > '2016.01.01') AND cAddress IS NULL;

-- 24. Show the country codes for countries with publishing companies. Exclude repeated values.
SELECT DISTINCT tpublishingcompany.nCountryID
FROM tpublishingcompany;

-- 25. Show the titles of books whose title starts by "The Tale" and that are not published by "Lynch Inc".
SELECT cTitle FROM tbook WHERE cTitle LIKE 'The Tale%' or tbook.cTitle LIKE '% The Tale%';


-- 26. Show the list of themes for which the publishing company "Lynch Inc" has published books, excluding repeated values.
SELECT DISTINCT ttheme.cName
FROM ttheme
JOIN tbooktheme on ttheme.nThemeID = tbooktheme.nThemeID
JOIN tbook on tbooktheme.nBookID = tbook.nBookID
JOIN tpublishingcompany ON tbook.nPublishingCompanyID = tpublishingcompany.nPublishingCompanyID
WHERE tpublishingcompany.cName = 'Lynch Inc'
GROUP BY ttheme.cName;

-- 27. Show the titles of those books which have never been loaned.
SELECT cTitle, tbookcopy.nBookID
FROM tbook
LEFT JOIN tbookcopy
ON tbook.nBookID = tbookcopy.nBookID
LEFT JOIN tloan
ON tbookcopy.cSignature = tloan.cSignature
WHERE tbookcopy.nBookID IS NULL;


-- 28. For each publishing company, show its number of existing books under the heading "No. of Books".
SELECT tpublishingcompany.cName, COUNT(*) AS 'Number of Books'
FROM tpublishingcompany
JOIN tbook t on tpublishingcompany.nPublishingCompanyID = t.nPublishingCompanyID
GROUP BY tpublishingcompany.cName;

-- 29.    Show the number of members who took some book on a loan during 2013.
SELECT COUNT(DISTINCT tmember.cName) AS 'Loans' FROM tmember
JOIN tloan ON tmember.cCPR = tloan.cCPR
WHERE dLoan BETWEEN '2013-01-01' AND '2013-12-31';

-- 30. For each book that has at least two authors, show its title and number of authors under the heading "No. of Authors".
SELECT tbook.cTitle, COUNT(tauthor.nAuthorID) AS 'Number. of Authors'
FROM tbook
JOIN tauthorship ON tbook.nBookID = tauthorship.nBookID
JOIN tauthor ON tauthorship.nAuthorID = tauthor.nAuthorID
GROUP BY tbook.cTitle
HAVING COUNT(tauthor.nAuthorID) > 1;
