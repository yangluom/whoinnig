#!/usr/bin/perl

use strict;


my @allData = ParseINNMedNet();

sub ParseINNMedNet
{
    my $inRow = 0;
    my $inData = 0;
    my $column = -1;
    my @allData = ();
    my @data   = ();

    while(<>)
    {
        chomp;

        if(/\<tr.*\>/)
        {
            $inRow  =  1;
            $column = -1;
            @data   = ();
        }
        elsif(/\<\/tr\>/)
        {
            $inRow = 0;
            CleanData(\@data);
            StoreData(\@allData, \@data);
        }
        elsif($inRow)
        {
            if(/\<td\>/)
            {
                $column++;
                if(/\<td\>(.*)\<\/td\>/)
                {
                    $data[$column] = $1;
                }
                else
                {
                    $inData = 1;
                    $data[$column] = '';
                }
            }
            elsif(/\<\/td\>/)
            {
                $inData = 0;
            }
            elsif($inData)
            {
                s/^\s+//;
                s/\s+$//;
                $data[$column] .= $_;
            }
        }
    }
    return(@allData); 
}


sub CleanData
{
    my($aData) = @_;

    my $nData = scalar(@$aData);

    for(my $i=0; $i<$nData; $i++)
    {
        if($i==0)
        {
            if($$aData[$i] =~ /\<a\s+href=['"](.*?)['"]/)
            {
                $$aData[$i] = $1;
            }
            else
            {
                $$aData[$i] = "NULL";
            }
        }
        else
        {
            $$aData[$i] =~ s/\<.*?\>//g;
            $$aData[$i] =~ s/&nbsp;//;
            $$aData[$i] =~ s/^\s+//;
            $$aData[$i] =~ s/\s+$//;
        }
    }
}


sub PrintData
{
    my($aData) = @_;

    printf("%-20s %5d %-35s %4d %4d\n",
           $$aData[0], $$aData[2], $$aData[3], $$aData[4], $$aData[5]);
}

sub StoreData
{
    my($aAllData, $aData) = @_;

    push @$aAllData, {url=>$$aData[0], id=>$$aData[2], name=>$$aData[3],
                      proposed=>$$aData[4], recommended=>$$aData[5]};
}
