
"""
FILE: skeleton_parser.py
------------------
Author: Garrett Schlesinger (gschles@cs.stanford.edu)
Author: Chenyu Yang (chenyuy@stanford.edu)
Modified: 10/13/2012

Skeleton parser for cs145 programming project 1. Has useful imports and
functions for parsing, including:

1) Directory handling -- the parser takes a list of eBay xml files
and opens each file inside of a loop. You just need to fill in the rest.
2) Dollar value conversions -- the xml files store dollar value amounts in 
a string like $3,453.23 -- we provide a function to convert it to a string
like XXXXX.xx.
3) Date/time conversions -- the xml files store dates/ times in the form 
Mon-DD-YY HH:MM:SS -- we wrote a function (transformDttm) that converts to the
for YYYY-MM-DD HH:MM:SS, which will sort chronologically in SQL.
4) A function to get the #PCDATA of a given element (returns the empty string
if the element is not of #PCDATA type)
5) A function to get the #PCDATA of the first subelement of a given element with
a given tagname. (returns the empty string if the element doesn't exist or 
is not of #PCDATA type)
6) A function to get all elements of a specific tag name that are children of a
given element
7) A function to get only the first such child

Your job is to implement the parseXml function, which is invoked on each file by
the main function. We create the dom for you; the rest is up to you! Get familiar 
with the functions at http://docs.python.org/library/xml.dom.minidom.html and 
http://docs.python.org/library/xml.dom.html

Happy parsing!
"""
import os
import sys
from xml.dom.minidom import parse
from re import sub

columnSeparator = "<>"

# Dictionary of months used for date transformation
MONTHS = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',\
                'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'}


"""
Returns true if a file ends in .xml
"""
def isXml(f):
    return len(f) > 4 and f[-4:] == '.xml'

"""
Non-recursive (NR) version of dom.getElementsByTagName(...)
"""
def getElementsByTagNameNR(elem, tagName):
    elements = []
    children = elem.childNodes
    for child in children:
        if child.nodeType == child.ELEMENT_NODE and child.tagName == tagName:
            elements.append(child)
    return elements

"""
Returns the first subelement of elem matching the given tagName,
or null if one does not exist.
"""
def getElementByTagNameNR(elem, tagName):
    children = elem.childNodes
    for child in children:
        if child.nodeType == child.ELEMENT_NODE and child.tagName == tagName:
            return child
    return None

"""
Parses out the PCData of an xml element
"""
def pcdata(elem):
        return elem.toxml().replace('<'+elem.tagName+'>','').replace('</'+elem.tagName+'>','').replace('<'+elem.tagName+'/>','')

"""
Return the text associated with the given element (which must have type
#PCDATA) as child, or "" if it contains no text.
"""
def getElementText(elem):
    if len(elem.childNodes) == 1:
        return pcdata(elem) 
    return ''

"""
Returns the text (#PCDATA) associated with the first subelement X of e
with the given tagName. If no such X exists or X contains no text, "" is
returned.
"""
def getElementTextByTagNameNR(elem, tagName):
    curElem = getElementByTagNameNR(elem, tagName)
    if curElem != None:
        return pcdata(curElem)
    return ''

"""
Converts month to a number, e.g. 'Dec' to '12'
"""
def transformMonth(mon):
    if mon in MONTHS:
        return MONTHS[mon] 
    else:
        return mon

"""
Transforms a timestamp from Mon-DD-YY HH:MM:SS to YYYY-MM-DD HH:MM:SS
"""
def transformDttm(dttm):
    dttm = dttm.strip().split(' ')
    dt = dttm[0].split('-')
    date = '20' + dt[2] + '-'
    date += transformMonth(dt[0]) + '-' + dt[1]
    return date + ' ' + dttm[1]

"""
Transform a dollar value amount from a string like $3,453.23 to XXXXX.xx
"""

def transformDollar(money):
    if money == None or len(money) == 0:
        return money
    return sub(r'[^\d.]', '', money)

def printXmlNode(node):
    print node.toxml()

def write_element(element, outfile):
    
    if "" == element:
        outfile.write("NULL")
    else:
        outfile.write(element)

def printArrayToFile(array, outfile):
    
    i=0
    for element in array:
        print element 
        if 0==i:
            write_element(element, outfile)
            i=1
        else:
            outfile.write(columnSeparator)
            write_element(element, outfile)
    outfile.write("\n")

def printUser(user_array, outfile, debug):
    if debug:
        print "Printing User To File..."
        print "UID: ", user_array[0]
        print "Rating: ", user_array[1]
        print "Location: ", user_array[2]
        print "Country: ", user_array[3]
    
    printArrayToFile(user_array, outfile)

def parseUser(seller_xml,seller_loc,seller_country, debug):
    seller_uid = seller_xml.getAttributeNode("UserID").nodeValue
    seller_rating = seller_xml.getAttributeNode("Rating").nodeValue

    if debug:
        print "Seller/Buyer UID: ", seller_uid
        print "Seller/Buyer Rating: ", seller_rating
        print "Seller/Buyer Location: ", seller_loc
        print "Seller/Buyer Country: ", seller_country

    seller_array = [ seller_uid, seller_rating, seller_loc, seller_country]

    return seller_array

def parseTime(item_xml, out_file, debug):
    if debug:
        print "Parsing Time..."

    item_id = item_xml.getAttributeNode("ItemID").nodeValue
    started = getElementTextByTagNameNR(item_xml, "Started")
    ends = getElementTextByTagNameNR(item_xml, "Ends")

    started = transformDttm(started)
    ends = transformDttm(ends)

    time_array = [item_id, started, ends]

    printArrayToFile(time_array, out_file)

def parseItem(item_xml,seller_id, out_file, debug):
    if debug:
        print "Parsing Item..."

    item_id = item_xml.getAttributeNode("ItemID").nodeValue
    name = getElementTextByTagNameNR(item_xml, "Name")
    description = getElementTextByTagNameNR(item_xml, "Description")
    num_of_bids = getElementTextByTagNameNR(item_xml, "Number_Of_Bids")

    if debug:
        print "item_id: ", item_id
        print "name: ", name
        print "description: ", description
        print "num_of_bids: ", num_of_bids

    item_array = [item_id,seller_id, name, description, num_of_bids]
    printArrayToFile(item_array, out_file)    

def parseItemRelations(item, out_file_dic, debug):
    
    seller_array = parseUsers(item,out_file_dic, debug)
   
    parseCat(item,out_file_dic["cat"], debug)

    parsePrice(item, out_file_dic["price"], debug)

    parseTime(item, out_file_dic["time"], debug)

    parseItem(item,seller_array[0], out_file_dic["item"], debug)


#def parseBid(item_xml, out_file, debug)

def parsePrice(item_xml, out_file, debug):
    if debug:
        "Parsing Price..."

    item_id = item_xml.getAttributeNode("ItemID").nodeValue
    first_bid = getElementTextByTagNameNR(item_xml, "First_Bid")  
    buy_price = getElementTextByTagNameNR(item_xml, "Buy_Price")
    currently = getElementTextByTagNameNR(item_xml, "Currently")

    first_bid = transformDollar(first_bid)
    buy_price = transformDollar(buy_price)
    currently = transformDollar(currently)

    price_array = [item_id, first_bid, buy_price, currently]

    printArrayToFile(price_array, out_file)

def parseCat(item_xml, out_file, debug):
    if debug:
        "Parsing Category..."
   
    cats_xml_array = getElementsByTagNameNR(item_xml, "Category")
    item_id = item_xml.getAttributeNode("ItemID").nodeValue
    for cat_xml in cats_xml_array:
        cat = getElementText(cat_xml)
        cat_array = [item_id, cat]

        printArrayToFile(cat_array,out_file)

def parseUsers(item, out_file_dic, debug):
    if debug:
        print "Parsing Users" 

    seller_array=parseUser(getElementByTagNameNR(item, "Seller"), \
                                              getElementTextByTagNameNR(item, "Location"), \
                                              getElementTextByTagNameNR(item, "Country"), debug)

    bidder_array2 = []
    bids_xml = getElementByTagNameNR(item, "Bids")
    bid_xml_array = getElementsByTagNameNR(bids_xml, "Bid")
    for bid_xml in bid_xml_array:
        bidder_xml = getElementByTagNameNR(bid_xml, "Bidder")
        bidder_array=parseUser(bidder_xml , \
                           getElementTextByTagNameNR(bidder_xml, "Location"), \
                           getElementTextByTagNameNR(bidder_xml, "Country"), debug)
        parseBid(item,bid_xml, bidder_xml, out_file_dic["bid"], debug)
        bidder_array2.append(bidder_array)


    bidder_array2.append(seller_array)
    user_array2 = bidder_array2
    for user_array in user_array2:
       printUser(user_array, out_file_dic["user"],debug)

    return seller_array

def parseBid(item_xml,bid_xml, bidder_xml, out_file, debug):
    if debug:
        print "Parsing Bid..."
    
    item_id = item_xml.getAttributeNode("ItemID").nodeValue
    bidder_id = bidder_xml.getAttributeNode("UserID").nodeValue
    time = getElementTextByTagNameNR(bid_xml, "Time")
    amount = getElementTextByTagNameNR(bid_xml, "Amount")

    bid_array = [item_id, bidder_id, time, amount]

    printArrayToFile(bid_array, out_file)
    
"""
Parses a single xml file. Currently, there's a loop that shows how to parse
item elements. Your job is to mirror this functionality to create all of the necessary SQL tables
"""
def parseXml(f):
    dom = parse(f) # creates a dom object for the supplied xml file
    """
    TO DO: traverse the dom tree to extract information for your SQL tables
    """
    out_file_dic = {}
    
    out_file_n = os.path.basename(f)
    out_file_n = out_file_n[0:-4]+"-SQLBULK"
    #print "Creating User  Output File: ", out_file_n
    user_file_n = out_file_n+"_USERS.dat"
    user_file = open(user_file_n, "w")
    out_file_dic["user"]=user_file

    cat_file_n = out_file_n+"_CAT.dat"
    out_file_dic["cat"] = open(cat_file_n, "w")

    price_file_n = out_file_n+"_PRICE.dat"
    out_file_dic["price"] = open(price_file_n, "w")

    time_file_n = out_file_n+"_TIME.dat"
    out_file_dic["time"] = open(time_file_n, "w")

    item_file_n = out_file_n+"_ITEM.dat"
    out_file_dic["item"] = open(item_file_n, "w")

    bid_file_n = out_file_n+"_BID.dat"
    out_file_dic["bid"] = open(bid_file_n, "w")

    print "Parsing XML Document..."

    print "Getting Items "
    #items = printXmlNode(dom.childNodes[1])
    items_xml = getElementByTagNameNR(dom, "Items")

    print "Getting Individual Items"
    item_xml_array = getElementsByTagNameNR(items_xml, "Item")

    print "Parsing Item Array"
    
    debug =  6
    for item in item_xml_array:
        parseItemRelations(item, out_file_dic, 0)
        debug = debug + 1


"""
Loops through each xml files provided on the command line and passes each file
to the parser
"""
def main(argv):
    if len(argv) < 2:
        print >> sys.stderr, 'Usage: python skeleton_parser.py <path to xml files>'
        sys.exit(1)
    # loops over all .xml files in the argument
    for f in argv[1:]:
        if isXml(f):
            parseXml(f)
            print "Success parsing " + f

if __name__ == '__main__':
    main(sys.argv)
