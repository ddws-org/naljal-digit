/*
 *    eGov  SmartCity eGovernance suite aims to improve the internal efficiency,transparency,
 *    accountability and the service delivery of the government  organizations.
 *
 *     Copyright (C) 2018  eGovernments Foundation
 *
 *     The updated version of eGov suite of products as by eGovernments Foundation
 *     is available at http://www.egovernments.org
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program. If not, see http://www.gnu.org/licenses/ or
 *     http://www.gnu.org/licenses/gpl.html .
 *
 *     In addition to the terms of the GPL license to be adhered to in using this
 *     program, the following additional terms are to be complied with:
 *
 *         1) All versions of this program, verbatim or modified must carry this
 *            Legal Notice.
 *            Further, all user interfaces, including but not limited to citizen facing interfaces,
 *            Urban Local Bodies interfaces, dashboards, mobile applications, of the program and any
 *            derived works should carry eGovernments Foundation logo on the top right corner.
 *
 *            For the logo, please refer http://egovernments.org/html/logo/egov_logo.png.
 *            For any further queries on attribution, including queries on brand guidelines,
 *            please contact contact@egovernments.org
 *
 *         2) Any misrepresentation of the origin of the material is prohibited. It
 *            is required that all modified versions of this material be marked in
 *            reasonable ways as different from the original version.
 *
 *         3) This license does not grant any rights to any user of the program
 *            with regards to rights under trademark law for use of the trade names
 *            or trademarks of eGovernments Foundation.
 *
 *   In case of any queries, you can reach eGovernments Foundation at contact@egovernments.org.
 *
 */

package org.egov.tl.repository.specs;

import org.egov.tl.entity.TradeLicense;
import org.egov.tl.entity.contracts.SearchForm;
import org.springframework.data.jpa.domain.Specification;

import javax.persistence.criteria.Predicate;

public final class SearchTradeSpec {

    private SearchTradeSpec() {
        //static methods only
    }

    public static Specification<TradeLicense> searchTrade(final SearchForm searchForm) {
        return (root, query, builder) -> {
            final Predicate predicate = builder.conjunction();
            if (searchForm.getLicenseNumber() != null)
                predicate.getExpressions().add(builder.equal(root.get("licenseNumber"), searchForm.getLicenseNumber()));
            if (searchForm.getApplicationNumber() != null)
                predicate.getExpressions().add(builder.equal(root.get("applicationNumber"), searchForm.getApplicationNumber()));
            if (searchForm.getOldLicenseNumber() != null)
                predicate.getExpressions().add(builder.equal(root.get("oldLicenseNumber"), searchForm.getOldLicenseNumber()));
            if (searchForm.getCategoryId() != null)
                predicate.getExpressions().add(builder.equal(root.get("category").get("id"), searchForm.getCategoryId()));
            if (searchForm.getSubCategoryId() != null)
                predicate.getExpressions().add(builder.equal(root.get("tradeName").get("id"), searchForm.getSubCategoryId()));
            if (searchForm.getTradeTitle() != null)
                predicate.getExpressions().add(builder.equal(root.get("nameOfEstablishment"), searchForm.getTradeTitle()));
            if (searchForm.getStatusId() != null)
                predicate.getExpressions().add(builder.equal(root.get("status").get("id"), searchForm.getStatusId()));
            if (searchForm.getTradeOwnerName() != null)
                predicate.getExpressions()
                        .add(builder.equal(root.get("licensee").get("applicantName"), searchForm.getTradeOwnerName()));
            if (searchForm.getPropertyAssessmentNo() != null)
                predicate.getExpressions().add(builder.equal(root.get("assessmentNo"), searchForm.getPropertyAssessmentNo()));
            if (searchForm.getMobileNo() != null)
                predicate.getExpressions()
                        .add(builder.equal(root.get("licensee").get("mobilePhoneNumber"), searchForm.getMobileNo()));
            if (searchForm.getInactive() != null && searchForm.getInactive().equals(Boolean.TRUE))
                predicate.getExpressions().add(builder.equal(root.get("isActive"), false));
            if (searchForm.getApplicationTypeId() != null)
                predicate.getExpressions()
                        .add(builder.equal(root.get("licenseAppType").get("id"), searchForm.getApplicationTypeId()));
            predicate.getExpressions().add(builder.isNotNull(root.get("applicationNumber")));
            if (searchForm.getNatureOfBusinessId() != null)
                predicate.getExpressions().add(builder.equal(root.get("natureOfBusiness"), searchForm.getNatureOfBusinessId()));

            return predicate;
        };
    }

}
