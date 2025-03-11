import lxml.etree as ET

def convert_xml_to_html(xml_report_path, xslt_path, html_report_path):
    # Parse the XML and XSLT files
    xml_tree = ET.parse(xml_report_path)
    xslt_tree = ET.parse(xslt_path)

    # Create and apply the transformation
    transform = ET.XSLT(xslt_tree)
    html_result = transform(xml_tree)

    # Write the result to an HTML file
    with open(html_report_path, 'wb') as f:
        f.write(ET.tostring(html_result, pretty_print=True, method='html'))

if __name__ == '__main__':
    # Ask for the paths
    xml_report_path = input("Enter path to your XML file: ")
    xslt_path = input("Enter path to your XSLT file: ")
    html_report_path = input("Enter desired path for the output HTML file: ")

    convert_xml_to_html(xml_report_path, xslt_path, html_report_path)
