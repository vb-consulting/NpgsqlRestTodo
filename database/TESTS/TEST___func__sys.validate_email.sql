do
$$
declare
    _record record;
begin
    for _record in (select * from (values
        ('ValidDomain', 'email@example.com', TRUE),
        ('WebIsDomain', 'email@example.web', TRUE),
        ('DotInAddress', 'firstname.lastname@example.com', TRUE),
        ('DotInSubdomain', 'email@subdomain.example.com', TRUE),
        ('PlusInAddress', 'firstname+lastname@example.com', TRUE),
        ('DomainIsValidIPAddress', 'email@123.123.123.123', TRUE),
        ('DomainIsValidIPAddressInBrackets', 'email@[123.123.123.123]', TRUE),
        ('QuotedAddress', '"email"@example.com', TRUE),
        ('DigitsInAddress', '1234567890@example.com', TRUE),
        ('DashInDomain', 'email@example-one.com', TRUE),
        ('UnderscoreAddress', '_______@example.com', TRUE),
        ('DashInAddress', 'firstname-lastname@example.com', TRUE),
        ('ListOfAddresses1', 'email1@example.com, email2@example.com', FALSE),
        ('ListOfAddresses2', 'email1@example.com; email2@example.com', FALSE),
        ('ListOfAddresses3', 'email1@example.com email2@example.com', FALSE),
        ('EmptyString', '', FALSE),
        ('MissingAtAndDomain', 'plainaddress', FALSE),
        ('Garbage', '#@%^%#$@#$@#.com', FALSE),
        ('MisingAddress', '@example.com', FALSE),
        ('EncodedHtml', 'Joe Smith <email@example.com>', FALSE),
        ('MissingAt', 'email.example.com', FALSE),
        ('TwoAtSigns', 'email@example@example.com', FALSE),
        ('LeadingDot', '.email@example.com', FALSE),
        ('TrailingDotInAddress', 'email@example.com.', FALSE),
        ('MultipleDotsAddress', 'email..email@example.com', FALSE),
        ('UnicodeInAddress', 'あいうえお@example.com', FALSE),
        ('TextAfterEmail', 'email@example.com (Joe Smi)', FALSE),
        ('MissingTopLevelDomain', 'email@example', TRUE),
        ('LeadingDashDomain', 'email@-example.com', TRUE),
        ('MultipleDotsInDomain', 'email@example..com', FALSE),
        ('NotRight1', '"(),:;<>[\]@example.com', FALSE),
        ('MultipleQuotes', 'just"not"right@example.com', FALSE),
        ('NotAllowed', 'this\isreally"not\allowed@example.com', FALSE),
        ('VeryVeryUnusual1', 'very."(),:;<>[]".VERY."very@\"very".unusual@strange.example.com', TRUE),
        ('VeryVeryUnusual2', 'very."(),:;<>[]".VERY."very"very".unusual@strange.example.com', FALSE),
        ('MuchMoreUnusal', 'much."more\ unusual"@example.com', TRUE),
        ('VeryUnusual', 'very.unusual."@".unusual.com@example.com', TRUE)) t (id, test, expected)
    ) loop
        assert sys.validate_email(_record.test) = _record.expected, 'Test ' || _record.id || ' failed.';
    end loop;

    -- All tests passed
    raise notice 'All validate email tests passed successfully!';
end
$$;
